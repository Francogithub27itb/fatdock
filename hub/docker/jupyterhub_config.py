# JupyterHub configuration
#
## If you update this file, do not forget to delete the `jupyterhub_data` volume before restarting the jupyterhub service:
##
##     docker volume rm jupyterhub_jupyterhub_data
##
## or, if you changed the COMPOSE_PROJECT_NAME to <name>:
##
##    docker volume rm <name>_jupyterhub_data
##
##

import os
import sys
import csv

c = get_config()

c.JupyterHub.tornado_settings.cookie_options = dict(expires_days=0.4125, max_age_days=0.4125)

c.JupyterHub.redirect_to_server = False

pwd = os.path.dirname(__file__)

# Same uid and gid is used for all instructors, and similarly same uid and gid are used for all students.
# A linux user with the same uid as instructor_uid and with
# the same primary gid as instructor_gid should exist on the host machine.
# This linux account should be used by instructors to manage assignment files.
# Even though all students will have same id inside their separate docker containers.
# Students won't be able to access each other's files because each
# of them will have different docker volumes mounted on their home directories inside container.

instructor_uid = os.environ['INSTRUCTOR_UID']
instructor_gid = os.environ['INSTRUCTOR_GID']
student_uid = os.environ['STUDENT_UID']
student_gid = os.environ['STUDENT_GID']

# Host directories where volumes are mounted
instructors_volumes_host_dir = os.environ['INSTRUCTORS_VOLUMES_HOST_DIR']
students_volumes_host_dir = os.environ['STUDENTS_VOLUMES_HOST_DIR']
exchange_host_dir = os.environ['EXCHANGE_HOST_DIR']
instructors_shared_notebooks_host_dir=os.environ['INSTRUCTORS_SHARED_NOTEBOOKS_HOST_DIR']

userlists_dir_host=os.environ['USERLISTS_HOST_DIR']
course_name = os.environ['COURSE_NAME']
notebook_dir_relative = os.environ['DOCKER_NOTEBOOK_DIR']

## host port for jupyterhub (inside container is always 8000)
host_port=os.environ['HOST_PORT']

c.JupyterHub.template_vars = {'announcement': f'Pluralcamp Labs: {course_name}'}

## Authenticator

instructors = []

from tornado import gen

from ltiauthenticator import LTIAuthenticator
from ltiauthenticator import LTILaunchValidator

class MyLTIAuthenticator(LTIAuthenticator):
    @gen.coroutine  
    def authenticate(self, handler, data=None):
        
        # FIXME: Run a process that cleans up old nonces every other minute
        validator = LTILaunchValidator(self.consumers)

        args = {}
        for k, values in handler.request.body_arguments.items():
            args[k] = values[0].decode() if len(values) == 1 else [v.decode() for v in values]

        # handle multiple layers of proxied protocol (comma separated) and take the outermost
        if 'x-forwarded-proto' in handler.request.headers:
            # x-forwarded-proto might contain comma delimited values
            # left-most value is the one sent by original client
            hops = [h.strip() for h in handler.request.headers['x-forwarded-proto'].split(',')]
            protocol = hops[0]
        else:
            protocol = handler.request.protocol

        launch_url = protocol + "://" + handler.request.host + handler.request.uri

        if validator.validate_launch_request(
                launch_url,
                handler.request.headers,
                args
        ):
            # Before we return lti_user_id, check to see if a canvas_custom_user_id was sent. 
            # If so, this indicates two things:
            # 1. The request was sent from Canvas, not edX
            # 2. The request was sent from a Canvas course not running in anonymous mode
            # If this is the case we want to use the canvas ID to allow grade returns through the Canvas API
            # If Canvas is running in anonymous mode, we'll still want the 'user_id' (which is the `lti_user_id``)

            canvas_id = handler.get_body_argument('custom_canvas_user_id', default=None)

            if canvas_id is not None:
                user_id = handler.get_body_argument('custom_canvas_user_id')
            else:
                user_id = handler.get_body_argument('user_id')

	    
            # If it is moodle, change numeric moodle id for username
            # Add moodle teachers as jupyterhub admins and nbgrader instructors

            is_moodle = handler.get_body_argument('tool_consumer_info_product_family_code', default=None)
            if is_moodle == 'moodle':
                moodle_id = handler.get_body_argument('ext_user_username', default=None)            
                if moodle_id is not None:
                    user_id = handler.get_body_argument('ext_user_username')            
                    #user_id = handler.get_body_argument('user_id')
                roles = handler.get_body_argument('roles', default=None)
                if 'nstructor' in roles:
                    moodle_id = handler.get_body_argument('user_id')
                    first_name = handler.get_body_argument('lis_person_name_given')
                    last_name = handler.get_body_argument('lis_person_name_family')
                    email = handler.get_body_argument('lis_person_contact_email_primary')
                    dict_line = {
                        'id': user_id,
                        'moodle_id': moodle_id,
                        'first_name': first_name,
                        'last_name': last_name,
                        'email': email
                    }                    
                    # adding moodle teacher as nbgrader instructor:
                    instructors.append(dict_line)               
   
                    # adding moodle teacher as jupyterhub admin:                      
                    self.admin_users.add(dict_line['id'])                    

            # to check out the contents of the headers, i.e. the data
            # sent by the LTI consumer:
            #self.save_post_headers(args,"/log_headers")
                                        
            return {
                'name': user_id,
                'auth_state': {k: v for k, v in args.items() if not k.startswith('oauth_')}
            }
            
    def save_post_headers(self, args, file):
        keys_values = args.items()
        new_d = {str(key): str(value) for key, value in keys_values}
        file = open(file,"a")
        file.write(str(new_d))
        file.close()
                        
c.JupyterHub.authenticator_class = MyLTIAuthenticator

# LTI Consumer is lms (moodle, canvas...)
LTI_consumer_key = os.environ['LTI_AUTH_KEY']
LTI_consumer_secret = os.environ['LTI_AUTH_SECRET']

c.LTIAuthenticator.consumers = {
    LTI_consumer_key: LTI_consumer_secret
}

## Generic
c.JupyterHub.admin_access = True
c.Spawner.default_url = '/lab'
c.Spawner.http_timeout = 40
display=os.environ['DISPLAY']

from dockerspawner import DockerSpawner

class MyDockerSpawner(DockerSpawner):
    def get_env(self):
        import os 
        env = super().get_env()
        env['NB_USER'] = env['NB_GROUP'] = self.user.name
        env['NOTEBOOK_DIR_RELATIVE'] = notebook_dir_relative
        env['JUPYTERHUB_USER'] = self.user.name
        env['CHOWN_HOME_OPTS'] = '-R'
        env['CHOWN_HOME'] = 'yes'
        env['HOME'] = os.path.join('/home' , self.user.name)
        env['COURSE_NAME'] = course_name
        env['DISPLAY'] = display
        #env['JUPYTERHUB_CLIENT_ID'] = f'jupyterhub-user-{self.user.name}'
        # Course home directory on container as setup by `singleuser/bin/start-custom.sh`
        env['COURSE_HOME_ON_CONTAINER'] = os.path.join(env['HOME'], notebook_dir_relative, 'courses', course_name)
        env['DOCKER_NOTEBOOK_DIR'] = os.path.join(env['HOME'], notebook_dir_relative)
        #env['JUPYTERHUB_SERVICE_PREFIX'] = os.path.join('/' , course_name, 'user', self.user.name) 
        #env['JUPYTERHUB_OAUTH_CALLBACK_URL'] = os.path.join(env['JUPYTERHUB_SERVICE_PREFIX'], 'oauth_callback')

        if self.is_instructor():
            env['IS_INSTRUCTOR'] = 'true'
            env['NB_UID'] = instructor_uid
            env['NB_GID'] = instructor_gid
            env['GRANT_SUDO'] = 'yes'
            return env

        # Hub user is not instructor.
        env['IS_INSTRUCTOR'] = 'false'
        env['NB_UID'] = student_uid
        env['NB_GID'] = student_gid
        return env
    
    # removes domain when username is email
    def trim_username(self):
        if '@' in self.user.name: 
            return self.user.name.split('@')[0]
        else:
            return self.user.name
  
    def is_instructor(self):
        for instructor in instructors:
            if self.user.name in instructor['id']:
                return True
        return False

    def start(self):
        #self.user.name = self.trim_username()
        if self.is_instructor():
            self.volumes[f'{instructors_volumes_host_dir}/{self.user.name}'] = {
                'bind': notebook_dir,
                'mode': 'rw',  # or ro for read-only
            }
            self.volumes[f'{instructors_shared_notebooks_host_dir}/{self.user.name}'] = {
                'bind': os.path.join(notebook_dir, 'my_notebooks'),
                'mode': 'rw',  # or ro for read-only
            }
        else:
            self.volumes[f'{students_volumes_host_dir}/{self.user.name}'] = {
                'bind': notebook_dir,
                'mode': 'rw',  # or ro for read-only
            }
        return super().start()

# spawn with Docker
c.JupyterHub.spawner_class = MyDockerSpawner
c.DockerSpawner.image = os.environ['DOCKER_JUPYTER_CONTAINER']
c.DockerSpawner.network_name = os.environ['DOCKER_NETWORK_NAME']

# See https://github.com/jupyterhub/dockerspawner/blob/master/examples/oauth/jupyterhub_config.py
c.JupyterHub.hub_connect_ip = os.environ['HUB_IP']
c.JupyterHub.hub_ip = '0.0.0.0'

# For docker, bind_url needs to be the name of the jupyterhub service as it is stated in docker-compose.yml
## this configuration option stablishes also the base_url
#c.JupyterHub.bind_url = f'http://jupyterhub_{course_name}:8000/{course_name}'
c.JupyterHub.bind_url = f'http://jupyterhub_{course_name}:8000'

c.DockerSpawner.name_template = "{prefix}-{username}-" + f"{course_name}"

home_dir = "/home/{username}"

notebook_dir = os.path.join(home_dir, notebook_dir_relative)  or '/home/jovyan/work'

c.DockerSpawner.notebook_dir = notebook_dir 

c.DockerSpawner.volumes = { exchange_host_dir: '/srv/nbgrader/exchange',  os.environ['COURSE_HOME_HOST_DIR'] : '/srv/nbgrader/courses/%s' % course_name, os.path.join(userlists_dir_host,'students'): '/tmp/csv' }


c.DockerSpawner.extra_host_config = {"cap_add": "LINUX_IMMUTABLE"}
#c.DockerSpawner.extra_host_config = {"cap_add": "SYS_PTRACE", "security_opt": ["seccomp=unconfined"]}

# Other stuff
c.Spawner.cpu_limit = 4
c.Spawner.mem_limit = '4G'

## Services

c.JupyterHub.services = [
    {
        'name': 'idle-culler',
        'admin': True,
        'command': [sys.executable, '-m', 'jupyterhub_idle_culler', '--timeout=1800'],
    },
]
#c.JupyterHub.services.append(
#    {
#        'name': 'ngshare',
#        'url': 'http://jupyterhub_dev:10101',
#        'admin': True,
#        'command': ['python3', '-m', 'ngshare', '--admins', 'orboan'],
#    }
#)

# should be set, which tells the hub to not stop servers when the hub restarts
c.JupyterHub.cleanup_servers = False
