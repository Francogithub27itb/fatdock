username = os.getenv('NB_USER')

home=f"/home/{username}"
workspaces = f"/home/{username}/workspaces"

jettyport = os.getenv('jettyport')
if not jettyport:
  jettyport = 8009

jenkinsport = os.getenv('jenkinsport')
if not jenkinsport:
  jenkinsport = 8011

portainerport = os.getenv('portainerport')
if not portainerport:
  portainerport = 9000

sonarport = os.getenv('sonarport')
if not sonarport:
  sonarport = 9090

c.ServerProxy.servers = {
    'code': {
      'command': ['/usr/bin/code-server', '--user-data-dir', '.config/Code/', '--extensions-dir', '.vscode/extensions/', '--bind-addr', '0.0.0.0:{port}', '--auth',  'none', '--disable-telemetry', '--disable-update-check', workspaces],
      'environment': {},
      'absolute_url': False,
      'timeout': 60,
      'launcher_entry': {
              'title': 'VS Code',
              'icon_path': os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                        'icons', 'vscode.svg')
      }
    },
    'pgadmin': {
      'command': [f'{home}/.local/bin/pg-start','{port}'],
      'timeout': 180,
      'port': 5050,
      'absolute_url': False,
      'launcher_entry': {
              'title': 'Pgadmin',
              'icon_path': '/etc/jupyter/icons/postgres.svg'
      }
    },
    'jetty': {
      'command': [f'{home}/.local/bin/jetty-start','{port}'],
      'port': int(f'{jettyport}'),
      'timeout': 120,
      'launcher_entry': {
              'enabled': True,
              'icon_path': '/etc/jupyter/icons/jetty.svg',
     	      'title': 'Jetty',
      },
    },
    'jenkins': {
      'command': [f'{home}/.local/bin/jenkins-start','{port}'],
      'port': int(f'{jenkinsport}'),
      'absolute_url': True,      
      'timeout': 120,
      'launcher_entry': {
              'enabled': True,
              'icon_path': '/etc/jupyter/icons/jenkins.svg',
              'title': 'Jenkins',
      },
    },
    'portainer': {
      'command': [f'{home}/.local/bin/pt-start','{port}'],
      'environment': {},
      'absolute_url': False,
      'timeout': 120,
      'port': int(f'{portainerport}'),
      'launcher_entry': {
              'title': 'Portainer',
              'icon_path': os.path.join(os.path.dirname(os.path.abspath(__file__)),
              'icons', 'docker.svg')
      },
    },
    'sonarqube': {
      'command': [f'{home}/.local/bin/sq-start','{port}'],
      'environment': {},
      'absolute_url': True,
      'timeout': 120,
      'port': int(f'{sonarport}'),
      'launcher_entry': {
              'title': 'Sonarqube',
              'icon_path': os.path.join(os.path.dirname(os.path.abspath(__file__)),
              'icons', 'sonarqube.svg')
      },
    },
}
