from kubespawner import KubeSpawner
from traitlets import Unicode
from jupyterhub.utils import exponential_backoff
from functools import partial
from kubernetes.client.models import V1PersistentVolumeClaim
from kubernetes.client.models import V1ObjectMeta
from kubernetes.client.models import V1PersistentVolumeClaimSpec
from kubernetes.client.models import V1ResourceRequirements

def make_pvc(
    name,
    storage_class,
    access_modes,
    selector,
    storage,
    labels=None,
    annotations=None,
):
    pvc = V1PersistentVolumeClaim()
    pvc.kind = "PersistentVolumeClaim"
    pvc.api_version = "v1"
    pvc.metadata = V1ObjectMeta()
    pvc.metadata.name = name
    pvc.metadata.annotations = (annotations or {}).copy()
    pvc.metadata.labels = (labels or {}).copy()
    pvc.spec = V1PersistentVolumeClaimSpec()
    pvc.spec.access_modes = access_modes
    pvc.spec.resources = V1ResourceRequirements()
    pvc.spec.resources.requests = {"storage": storage}

    if storage_class is not None:
        pvc.metadata.annotations.update(
            {"volume.beta.kubernetes.io/storage-class": storage_class}
        )
        pvc.spec.storage_class_name = storage_class

    if selector:
        pvc.spec.selector = selector

    return pvc
 
class ElMeuKubeSpawner(KubeSpawner):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # pv claim for sidecar container
        self.pvc_sc_name = self._expand_user_properties(self.pvc_sc_name_template)
        #self.pvc_docker_name = self._expand_user_properties(self.pvc_docker_name_template)
        self.pvc_ideap_name = self._expand_user_properties(self.pvc_ideap_name_template)
        self.pvc_mysql_name = self._expand_user_properties(self.pvc_mysql_name_template)
        # super(self).__init__(*args, **kwargs)

    pvc_sc_name_template = Unicode(
        'pg-claim-{username}',
        config=True,
        help="Template to use to form the name of postgres sidecars' pvc.",
    )          
    
    #pvc_docker_name_template = Unicode(
    #    'docker-claim-{username}',
    #    config=True,
    #    help="Template to use to form the name of docker sidecars' pvc.",
    #)    
    pvc_ideap_name_template = Unicode(
        'ideap-claim-{username}',
        config=True,
        help="Template to use to form the name of ideap sidecars' pvc.",
    )
    pvc_mysql_name_template = Unicode(
        'mysql-claim-{username}',
        config=True,
        help="Template to use to form the name of mysql sidecars' pvc.",
    )

    async def _start(self):
        """Start the user's pod"""

        # load user options (including profile)
        await self.load_user_options()

        # If we have user_namespaces enabled, create the namespace.
        #  It's fine if it already exists.
        if self.enable_user_namespaces:
            await self._ensure_namespace()

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
            pvc_sc = self.get_pvc_sc_manifest()

            # If there's a timeout, just let it propagate
            await exponential_backoff(
                partial(
                    self._make_create_pvc_request, pvc_sc, self.k8s_api_request_timeout
                ),
                f'Could not create PVC {self.pvc_sc_name}',
                # Each req should be given k8s_api_request_timeout seconds.
                timeout=self.k8s_api_request_retry_timeout,
            ) 

            #pvc_docker = self.get_pvc_docker_manifest()
            pvc_ideap = self.get_pvc_ideap_manifest()
            pvc_mysql = self.get_pvc_mysql_manifest()

            # If there's a timeout, just let it propagate
            #await exponential_backoff(
            #    partial(
            #        self._make_create_pvc_request, pvc_docker, self.k8s_api_request_timeout
            #    ),
            #    f'Could not create PVC {self.pvc_docker_name}',
            #    # Each req should be given k8s_api_request_timeout seconds.
            #    timeout=self.k8s_api_request_retry_timeout,
            #)           

            # If there's a timeout, just let it propagate
            await exponential_backoff(
                partial(
                    self._make_create_pvc_request, pvc_ideap, self.k8s_api_request_timeout
                ),
                f'Could not create PVC {self.pvc_ideap_name}',
                # Each req should be given k8s_api_request_timeout seconds.
                timeout=self.k8s_api_request_retry_timeout,
            )
            await exponential_backoff(
                partial(
                    self._make_create_pvc_request, pvc_mysql, self.k8s_api_request_timeout
                ),
                f'Could not create PVC {self.pvc_mysql_name}',
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

        if self.internal_ssl:
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
                        self._make_create_resource_request, "service", service_manifest
                    ),
                    f"Failed to create service {service_manifest.metadata.name}",
                )
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
                self._start_watching_pods(replace=True)
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

    def get_pvc_ideap_manifest(self):
        """
        Make a pvc manifest that will spawn current user's pvc.
        """
        labels = self._build_common_labels(self._expand_all(self.storage_extra_labels))
        labels.update({'component': 'singleuser-storage'})

        annotations = self._build_common_annotations({})

        storage_selector = self._expand_all(self.storage_selector)

        return make_pvc(
            name=self.pvc_ideap_name,
            storage_class=self.storage_class,
            access_modes=self.storage_access_modes,
            selector=storage_selector,
            storage=self.storage_capacity,
            labels=labels,
            annotations=annotations,
        )
    def get_pvc_mysql_manifest(self):
        """
        Make a pvc manifest that will spawn current user's pvc.
        """
        labels = self._build_common_labels(self._expand_all(self.storage_extra_labels))
        labels.update({'component': 'singleuser-storage'})

        annotations = self._build_common_annotations({})

        storage_selector = self._expand_all(self.storage_selector)

        return make_pvc(
            name=self.pvc_mysql_name,
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
                self.pvc_ideap_name,
                self.k8s_api_request_timeout,
            ),
            f'Could not delete pvc {self.pvc_ideap_name}',
            timeout=self.k8s_api_request_retry_timeout,
        )
        await exponential_backoff(
            partial(
                self._make_delete_pvc_request,
                self.pvc_mysql_name,
                self.k8s_api_request_timeout,
            ),
            f'Could not delete pvc {self.pvc_mysql_name}',
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
