"""
JupyterHub Spawner to spawn user notebooks on a Kubernetes cluster.

This module exports `KubeSpawner` class, which is the actual spawner
implementation that should be used by JupyterHub.
"""

## 

import asyncio
import copy
import ipaddress
import os
import re
import string
import sys
import warnings
from functools import partial
from typing import Optional, Tuple, Type
from urllib.parse import urlparse

import escapism
from jinja2 import ChoiceLoader, Environment, FileSystemLoader, PackageLoader
from jupyterhub.spawner import Spawner
from jupyterhub.traitlets import Callable, Command
from jupyterhub.utils import exponential_backoff, maybe_future
from kubespawner import KubeSpawner 
from kubernetes_asyncio import client
from kubernetes_asyncio.client.rest import ApiException
from slugify import slugify
from traitlets import (
    Bool,
    Dict,
    Integer,
    List,
    Unicode,
    Union,
    default,
    observe,
    validate,
)

from kubespawner.clients import load_config, shared_client
from kubespawner.objects import (
    make_namespace,
    make_owner_reference,
    make_pod,
    make_pvc,
    make_secret,
    make_service,
)
from kubespawner.reflector import ResourceReflector
from kubespawner.utils import recursive_format, recursive_update

from kubernetes.client.models import V1PersistentVolumeClaim
from kubernetes.client.models import V1ObjectMeta
from kubernetes.client.models import V1PersistentVolumeClaimSpec
from kubernetes.client.models import V1ResourceRequirements

from tornado import gen

class ElMeuKubeSpawner(KubeSpawner):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # pv claim for sidecar container
        self.pvc_dbdata_name = self._expand_user_properties(self.pvc_dbdata_name_template)
        self.pvc_dockerdata_name = self._expand_user_properties(self.pvc_dockerdata_name_template)
        self.pvc_apps_name = self._expand_user_properties(self.pvc_apps_name_template)
        self.pvc_conda_envs_name = self._expand_user_properties(self.pvc_conda_envs_name_template)
        # super(self).__init__(*args, **kwargs)
    pvc_dbdata_name_template = Unicode(
        'dbdata-claim-{username}',
        config=True,
        help="Template to use to form the name of dbdata sidecars' pvc.",
    )
    pvc_dockerdata_name_template = Unicode(
        'dockerdata-claim-{username}',
        config=True,
        help="Template to use to form the name of dockerdata sidecars' pvc.",
    )
    pvc_apps_name_template = Unicode(
        'apps-claim-{username}',
        config=True,
        help="Template to use to form the name of apps sidecars' pvc.",
    )
    pvc_conda_envs_name_template = Unicode(
        'conda-envs-claim-{username}',
        config=True,
        help="Template to use to form the name of conda envs sidecars' pvc.",
    )

    async def _start(self):
        """Start the user's pod"""

        # load user options (including profile)
        await self.load_user_options()

        # If we have user_namespaces enabled, create the namespace.
        #  It's fine if it already exists.
        if self.enable_user_namespaces:
            await self._ensure_namespace()

        # namespace can be changed via kubespawner_override, start watching pods only after
        # load_user_options() is called
        start_tasks = [self._start_watching_pods()]
        if self.events_enabled:
            start_tasks.append(self._start_watching_events())
        # create Futures for coroutines so we can cancel them
        # in case of an error
        start_futures = [asyncio.ensure_future(task) for task in start_tasks]
        try:
            await asyncio.gather(*start_futures)
        except Exception:
            # cancel any unfinished tasks before re-raising
            # because gather doesn't cancel unfinished tasks.
            # TaskGroup would do this cancel for us, but requires Python 3.11
            for future in start_futures:
                if not future.done():
                    future.cancel()
            raise

        # record latest event so we don't include old
        # events from previous pods in self.events
        # track by order and name instead of uid
        # so we get events like deletion of a previously stale
        # pod if it's part of this spawn process
        events = self.events
        if events:
            self._last_event = events[-1]["metadata"]["uid"]

        if self.storage_pvc_ensure:
            pvc = self.get_pvc_manifest()

            # If there's a timeout, just let it propagate
            await exponential_backoff(
                partial(
                    self._make_create_pvc_request, pvc, self.k8s_api_request_timeout
                ),
                f'Could not create PVC {self.pvc_name}',
                # Each req should be given k8s_api_request_timeout seconds.
                timeout=self.k8s_api_request_retry_timeout,
            )
        if self.storage_pvc_ensure:
            #pvc_docker = self.get_pvc_docker_manifest()
            pvc_dbdata = self.get_pvc_dbdata_manifest()
            pvc_dockerdata = self.get_pvc_dockerdata_manifest()
            pvc_apps = self.get_pvc_apps_manifest()
            pvc_conda_envs = self.get_pvc_conda_envs_manifest()

            # If there's a timeout, just let it propagate
            await exponential_backoff(
                partial(
                    self._make_create_pvc_request, pvc_dbdata, self.k8s_api_request_timeout
                ),
                f'Could not create PVC {self.pvc_dbdata_name}',
                # Each req should be given k8s_api_request_timeout seconds.
                timeout=self.k8s_api_request_retry_timeout,
            )
            await exponential_backoff(
                partial(
                    self._make_create_pvc_request, pvc_dockerdata, self.k8s_api_request_timeout
                ),
                f'Could not create PVC {self.pvc_dockerdata_name}',
                # Each req should be given k8s_api_request_timeout seconds.
                timeout=self.k8s_api_request_retry_timeout,
            )
            await exponential_backoff(
                partial(
                    self._make_create_pvc_request, pvc_apps, self.k8s_api_request_timeout
                ),
                f'Could not create PVC {self.pvc_apps_name}',
                # Each req should be given k8s_api_request_timeout seconds.
                timeout=self.k8s_api_request_retry_timeout,
            )
            await exponential_backoff(
                partial(
                    self._make_create_pvc_request, pvc_conda_envs, self.k8s_api_request_timeout
                ),
                f'Could not create PVC {self.pvc_conda_envs_name}',
                # Each req should be given k8s_api_request_timeout seconds.
                timeout=self.k8s_api_request_retry_timeout,
            )
        # If we run into a 409 Conflict error, it means a pod with the
        # same name already exists. We stop it, wait for it to stop, and
        # try again. We try 4 times, and if it still fails we give up.
        pod = await self.get_pod_manifest()
        if self.modify_pod_hook:
            pod = await gen.maybe_future(self.modify_pod_hook(self, pod))

        ref_key = "{}/{}".format(self.namespace, self.pod_name)
        # If there's a timeout, just let it propagate
        await exponential_backoff(
            partial(self._make_create_pod_request, pod, self.k8s_api_request_timeout),
            f'Could not create pod {ref_key}',
            timeout=self.k8s_api_request_retry_timeout,
        )
        if self.internal_ssl or self.services_enabled or self.after_pod_created_hook:
            try:
                # wait for pod to have uid,
                # required for creating owner reference
                await exponential_backoff(
                    lambda: self.pod_has_uid(
                        self.pod_reflector.pods.get(ref_key, None)
                    ),
                    f"pod/{ref_key} does not have a uid!",
                )

                pod = self.pod_reflector.pods[ref_key]
                owner_reference = make_owner_reference(
                    self.pod_name, pod["metadata"]["uid"]
                )
                if self.internal_ssl:
                    # internal ssl, create secret object
                    secret_manifest = self.get_secret_manifest(owner_reference)
                    await exponential_backoff(
                        partial(
                            self._ensure_not_exists, "secret", secret_manifest.metadata.name
                        ),
                        f"Failed to delete secret {secret_manifest.metadata.name}",
                    ) 
                    await exponential_backoff(
                        partial(
                            self._make_create_resource_request, "secret", secret_manifest
                        ),
                        f"Failed to create secret {secret_manifest.metadata.name}",
                    )

                if self.internal_ssl or self.services_enabled:
                    service_manifest = self.get_service_manifest(owner_reference)
                    await exponential_backoff(
                        partial(
                            self._ensure_not_exists,
                            "service",
                            service_manifest.metadata.name,
                        ),
                        f"Failed to delete service {service_manifest.metadata.name}",
                    )
                    await exponential_backoff(
                        partial(
                            self._make_create_resource_request,
                            "service",
                            service_manifest,
                        ),
                        f"Failed to create service {service_manifest.metadata.name}",
                    )

                if self.after_pod_created_hook:
                    self.log.info('Executing after_pod_created_hook')
                    await maybe_future(self.after_pod_created_hook(self, pod))
            except Exception:
                # cleanup on failure and re-raise
                await self.stop(True)
                raise

        # we need a timeout here even though start itself has a timeout
        # in order for this coroutine to finish at some point.
        # using the same start_timeout here
        # essentially ensures that this timeout should never propagate up
        # because the handler will have stopped waiting after
        # start_timeout, starting from a slightly earlier point.
        try:
            await exponential_backoff(
                lambda: self.is_pod_running(self.pod_reflector.pods.get(ref_key, None)),
                'pod %s did not start in %s seconds!' % (ref_key, self.start_timeout),
                timeout=self.start_timeout,
            )
        except TimeoutError:
            if ref_key not in self.pod_reflector.pods:
                # if pod never showed up at all,
                # restart the pod reflector which may have become disconnected.
                self.log.error(
                    "Pod %s never showed up in reflector, restarting pod reflector",
                    ref_key,
                )
                self.log.error("Pods: {}".format(self.pod_reflector.pods))
                asyncio.ensure_future(self._start_watching_pods(replace=True))
                #self._start_watching_pods(replace=True) ##old version
            raise

        pod = self.pod_reflector.pods[ref_key]
        self.pod_id = pod["metadata"]["uid"]
        if self.event_reflector:
            self.log.debug(
                'pod %s events before launch: %s',
                ref_key,
                "\n".join(
                    [
                        "%s [%s] %s"
                        % (
                            event["lastTimestamp"] or event["eventTime"],
                            event["type"],
                            event["message"],
                        )
                        for event in self.events
                    ]
                ),
            )

        return self._get_pod_url(pod)


    def get_pvc_sc_manifest(self):
        """
        Make a pvc manifest that will spawn current user's pvc.
        """
        labels = self._build_common_labels(self._expand_all(self.storage_extra_labels))
        labels.update({'component': 'singleuser-storage'})

        annotations = self._build_common_annotations({})

        storage_selector = self._expand_all(self.storage_selector)

        return make_pvc(
            name=self.pvc_sc_name,
            storage_class=self.storage_class,
            access_modes=self.storage_access_modes,
            selector=storage_selector,
            storage=self.storage_capacity,
            labels=labels,
            annotations=annotations,
        )

    def get_pvc_docker_manifest(self):
        """
        Make a pvc manifest that will spawn current user's pvc.
        """
        labels = self._build_common_labels(self._expand_all(self.storage_extra_labels))
        labels.update({'component': 'singleuser-storage'})

        annotations = self._build_common_annotations({})

        storage_selector = self._expand_all(self.storage_selector)

        return make_pvc(
            name=self.pvc_docker_name,
            storage_class=self.storage_class,
            access_modes=self.storage_access_modes,
            selector=storage_selector,
            storage=self.storage_capacity,
            labels=labels,
            annotations=annotations,
        )

    def get_pvc_dbdata_manifest(self):
        """
        Make a pvc manifest that will spawn current user's pvc.
        """
        labels = self._build_common_labels(self._expand_all(self.storage_extra_labels))
        labels.update({'component': 'singleuser-storage'})

        annotations = self._build_common_annotations({})

        storage_selector = self._expand_all(self.storage_selector)

        return make_pvc(
            name=self.pvc_dbdata_name,
            storage_class=self.storage_class,
            access_modes=self.storage_access_modes,
            selector=storage_selector,
            storage=self.storage_capacity,
            labels=labels,
            annotations=annotations,
        )

    def get_pvc_dockerdata_manifest(self):
        """
        Make a pvc manifest that will spawn current user's pvc.
        """
        labels = self._build_common_labels(self._expand_all(self.storage_extra_labels))
        labels.update({'component': 'singleuser-storage'})

        annotations = self._build_common_annotations({})

        storage_selector = self._expand_all(self.storage_selector)

        return make_pvc(
            name=self.pvc_dockerdata_name,
            storage_class=self.storage_class,
            access_modes=self.storage_access_modes,
            selector=storage_selector,
            storage=self.storage_capacity,
            labels=labels,
            annotations=annotations,
        )

    def get_pvc_apps_manifest(self):
        """
        Make a pvc manifest that will spawn current user's apps location pvc.
        """
        labels = self._build_common_labels(self._expand_all(self.storage_extra_labels))
        labels.update({'component': 'singleuser-storage'})

        annotations = self._build_common_annotations({})

        storage_selector = self._expand_all(self.storage_selector)

        return make_pvc(
            name=self.pvc_apps_name,
            storage_class=self.storage_class,
            access_modes=self.storage_access_modes,
            selector=storage_selector,
            storage=self.storage_capacity,
            labels=labels,
            annotations=annotations,
        )

    def get_pvc_conda_envs_manifest(self):
        """
        Make a pvc manifest that will spawn current user's conda envs location pvc.
        """
        labels = self._build_common_labels(self._expand_all(self.storage_extra_labels))
        labels.update({'component': 'singleuser-storage'})

        annotations = self._build_common_annotations({})

        storage_selector = self._expand_all(self.storage_selector)

        return make_pvc(
            name=self.pvc_conda_envs_name,
            storage_class=self.storage_class,
            access_modes=self.storage_access_modes,
            selector=storage_selector,
            storage=self.storage_capacity,
            labels=labels,
            annotations=annotations,
        )

    async def delete_forever(self):
        super().delete_forever()
        await exponential_backoff(
            partial(
                self._make_delete_pvc_request,
                self.pvc_sc_name,
                self.k8s_api_request_timeout,
            ),
            f'Could not delete pvc {self.pvc_sc_name}',
            timeout=self.k8s_api_request_retry_timeout,
        )
        await exponential_backoff(
            partial(
                self._make_delete_pvc_request,
                self.pvc_docker_name,
                self.k8s_api_request_timeout,
            ),
            f'Could not delete pvc {self.pvc_docker_name}',
            timeout=self.k8s_api_request_retry_timeout,
        )

        await exponential_backoff(
            partial(
                self._make_delete_pvc_request,
                self.pvc_dbdata_name,
                self.k8s_api_request_timeout,
            ),
            f'Could not delete pvc {self.pvc_dbdata_name}',
            timeout=self.k8s_api_request_retry_timeout,
        )
        await exponential_backoff(
            partial(
                self._make_delete_pvc_request,
                self.pvc_dockerdata_name,
                self.k8s_api_request_timeout,
            ),
            f'Could not delete pvc {self.pvc_dockerdata_name}',
            timeout=self.k8s_api_request_retry_timeout,
        )
        await exponential_backoff(
            partial(
                self._make_delete_pvc_request,
                self.pvc_apps_name,
                self.k8s_api_request_timeout,
            ),
            f'Could not delete pvc {self.pvc_apps_name}',
            timeout=self.k8s_api_request_retry_timeout,
        )
        await exponential_backoff(
            partial(
                self._make_delete_pvc_request,
                self.pvc_conda_envs_name,
                self.k8s_api_request_timeout,
            ),
            f'Could not delete pvc {self.pvc_conda_envs_name}',
            timeout=self.k8s_api_request_retry_timeout,
        )

c.JupyterHub.spawner_class = ElMeuKubeSpawner

## Instructors vs students

c.Spawner.cmd = ['start.sh','jupyterhub-singleuser','--allow-root']
c.ElMeuKubeSpawner.args = ['--allow-root']
def notebook_dir_hook(spawner):
    is_instructor='false'
    for instructor in instructors:
        f = open("/home/jovyan/instructor.out", "a")
        f.write(f"spawner.user.name = {spawner.user.name} - instructor id = {instructor['id']}")
        f.close()
        if spawner.user.name == instructor['id']:
            is_instructor='true'
            break
    spawner.environment = {'NB_USER':spawner.user.name,'NB_UID':'1000','IS_INSTRUCTOR':is_instructor}
c.Spawner.pre_spawn_hook = notebook_dir_hook
c.Spawner.http_timeout = 6000


