## Authenticator

instructors = []

from oauthenticator.github import LocalGitHubOAuthenticator
c.JupyterHub.authenticator_class = LocalGitHubOAuthenticator

# GitHub OAuth Login
c.LocalGitHubOAuthenticator.oauth_callback_url = 'https://hub.pluralcamp.com/hub/oauth_callback'
c.LocalGitHubOAuthenticator.client_id = 'ded2ee991f836097b78f'
c.LocalGitHubOAuthenticator.client_secret = '330ad1180cdb46fe948c001a7023283078861e4e'
#c.LocalGitHubOAuthenticator.create_system_users = True
c.LocalAuthenticator.create_system_users=True
c.Authenticator.delete_invalid_users = True
c.Authenticator.allowed_users = {'orboan'}
#c.Authenticator.whitelist = {'orboan'}
c.Authenticator.admin_users = {'orboan'}


