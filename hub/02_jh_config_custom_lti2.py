## Authenticator

instructors = []

from tornado import gen

#from ltiauthenticator import LTI11Authenticator
from ltiauthenticator.lti11.auth import LTI11Authenticator as LTIAuthenticator
#from ltiauthenticator import LTI11LaunchValidator as LTILaunchValidator
from ltiauthenticator.lti11.validator import LTI11LaunchValidator as LTILaunchValidator
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
                    user_id = str(handler.get_body_argument('ext_user_username')).split('@', 1)[0]
                    user_id = user_id.replace('.','') 
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
            # self.save_post_headers(args,"/log_headers")

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


# LTI Consumer is lms (moodle, canvas...)
LTI_consumer_key = 'a077a17a372c1ce773b40a1308101bace5343721509805b23fae8e94664ac343'
LTI_consumer_secret = '7e052b95f537756f1a3b1f05c896d1938c14ade7af318728395622a453bba541'

c.LTI11Authenticator.consumers = {
    LTI_consumer_key: LTI_consumer_secret
}
