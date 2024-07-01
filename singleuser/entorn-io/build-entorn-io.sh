#!/bin/bash

tag="0.1.2"

data_science=false
devops=false
dev=false

squash_base_image() {
   base_image=jupyter/all-spark-notebook
   docker build --squash -t entorn-io/data-base:squashed -f Dockerfile.squash \
	   --build-arg BASE_CONTAINER=$base_image \
           .
}

# versions
env_java_version=17.0.11
env_java_provider=ms
env_python_major_version=3.11
env_language=ca_ES
env_scala3_ver=3.3.0
env_ammonite_ver=2.5.11
env_npm_ver=10.8.1
#env_npm_ver=9.8.1
env_codeserver_ver=4.90.3
env_rstudio_ver="2024.04.2-764"
env_docker_ver=27.0.1
env_docker_compose_ver=2.28.1
env_mongo_ver=7
env_modelio_ver=5.4.1
env_turbovnc_ver=3.0


if [[ "$1" == "data" ]]; then
    #squash_base_image
    base_container=entorn/base:squashed
    data_science=true
    nbgrader=true
    #kernels
    java_kernel=true
    kotlin_kernel=true
    scala_kernel=true
    tslabs_kernel=true
    bash_kernel=false
    ansible_kernel=false
    php_kernel=false
    # apps
    xfc4=true
    brave=false
    selenium=true
    mysql=true
    mongo=true
    modelio=false
    turbovnc=true
    spice=false
    jupyterbook=true
    # proxy server:
    idea=false
    pgadmin=true
    jetty=false
    jenkins=false
    portainer=false
    heroku=false
    sonarqube=false
    gpc=true
    network_tools=false
elif [[ "$1" == "ops" ]]; then
    base_container=jupyter/minimal-notebook
    devops=true
    nbgrader=false
    #kernels
    java_kernel=true
    kotlin_kernel=false
    scala_kernel=false
    tslabs_kernel=true
    bash_kernel=true
    ansible_kernel=true
    php_kernel=false
    # apps
    xfc4=true
    brave=false
    selenium=true
    mysql=true
    mongo=false
    modelio=false
    turbovnc=true
    spice=false
    jupyterbook=true
    # proxy server:
    idea=false
    pgadmin=true
    jetty=false
    jenkins=true
    portainer=true
    heroku=true
    sonarqube=false
    gpc=true
    network_tools=true
elif [[ "$1" == "min" ]]; then
    base_container=jupyter/minimal-notebook
    devops=false
    nbgrader=false
    #kernels
    java_kernel=true
    kotlin_kernel=false
    scala_kernel=false
    tslabs_kernel=true
    bash_kernel=false
    ansible_kernel=false
    php_kernel=false
    # apps
    xfc4=true
    brave=false
    selenium=false
    mysql=true
    mongo=true
    modelio=false
    turbovnc=true
    spice=false
    jupyterbook=false
    # proxy server:
    idea=false
    pgadmin=false
    jetty=true
    jenkins=false
    portainer=false
    heroku=true
    sonarqube=false
    gpc=false
    network_tools=false
elif [[ "$1" == "full" ]]; then
    #squash_base_image
    base_container=entorn/base:squashed
    #base_container=jupyter/all-spark-notebook
    data_science=true
    nbgrader=true
    #kernels
    java_kernel=true
    kotlin_kernel=true
    scala_kernel=true
    tslabs_kernel=true
    bash_kernel=true
    ansible_kernel=true
    php_kernel=true
    # apps
    xfc4=true
    brave=true
    selenium=true
    mysql=true
    mongo=true
    modelio=true
    turbovnc=true
    spice=false
    jupyterbook=true
    # proxy server:
    idea=false
    pgadmin=true
    jetty=true
    jenkins=true
    portainer=true
    heroku=true
    sonarqube=true
    gpc=true
    network_tools=true
elif [[ "$1" == "javaweb" ]]; then
    mv ./resources/config/videochat/jupyter_server_config.json ./resources/config/videochat/jupyter_server_config.json.bak
    mv ./resources/config/videochat/jupyter_server_config.json.jbe ./resources/config/videochat/jupyter_server_config.json
    env_java_version=11.0.17
    #squash_base_image
    base_container=jupyter/minimal-notebook
    data_science=false
    nbgrader=false
    #kernels
    java_kernel=true
    kotlin_kernel=false
    scala_kernel=false
    tslabs_kernel=true
    bash_kernel=true
    ansible_kernel=false
    php_kernel=false
    # apps
    xfc4=true
    brave=false
    selenium=true
    mysql=true
    mongo=true
    modelio=true
    turbovnc=true
    spice=false
    jupyterbook=false
    # proxy server:
    idea=false
    pgadmin=false
    jetty=true
    jenkins=true
    portainer=true
    heroku=true
    sonarqube=true
    gpc=true
    network_tools=false    
else
    base_container=jupyter/minimal-notebook
    dev=true
    nbgrader=true
    #kernels
    java_kernel=true
    kotlin_kernel=true
    scala_kernel=true
    tslabs_kernel=true
    bash_kernel=false
    ansible_kernel=false
    php_kernel=false
    # apps
    xfc4=true
    brave=false
    selenium=true
    mysql=true
    mongo=true
    modelio=true
    turbovnc=true
    spice=false
    jupyterbook=true
    # proxy server:
    idea=false
    pgadmin=true
    jetty=true
    jenkins=true
    portainer=false
    heroku=true
    sonarqube=true
    gpc=true
    network_tools=false
fi

proxy_server_file=proxy-server.entorn-io.py

rm $proxy_server_file
cp ${proxy_server_file}.template $proxy_server_file

if [[ "$idea" == "true" ]]; then
cat <<EOT >> ${proxy_server_file}
    'idea': {
      'command': [f'/home/{username}/.local/bin/idea-start'],
      'timeout': 120,
      'port': 8887,
      'absolute_url': False,
      'launcher_entry': {
              'title': 'Idea',
              'icon_path': '/etc/jupyter/icons/projector.svg'
      }
    },
EOT
fi

if [[ "$pgadmin" == "true" ]]; then
cat <<EOT >> ${proxy_server_file}
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
EOT
fi

if [[ "$jetty" == "true" ]]; then
cat <<EOT >> ${proxy_server_file}
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
EOT
fi

if [[ "$jenkins" == "true" ]]; then
cat <<EOT >> ${proxy_server_file}
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
EOT
fi

if [[ "$portainer" == "true" ]]; then
cat <<EOT >> ${proxy_server_file}
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
EOT
fi

if [[ "$sonarqube" == "true" ]]; then
cat <<EOT >> ${proxy_server_file}
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
EOT
fi


echo "}" >> ${proxy_server_file}


# build docker image:

docker build -t entorn-io/singleuser-$1:$tag -f Dockerfile.entorn \
        --build-arg BASE_CONTAINER=$base_container \
	--build-arg DATA_SCIENCE=$data_science \
	--build-arg DEVOPS=$devops \
	--build-arg NBGRADER=$nbgrader \
	--build-arg java_version=$env_java_version \
	--build-arg java_provider=$env_java_provider \
        --build-arg python_major_version=$env_python_major_version \
	--build-arg language=$env_language \
	--build-arg SCALA3_VER=$env_scala3_ver \
	--build-arg AMMONITE_VER=$env_ammonite_ver \
	--build-arg NPM_VER=$env_npm_ver \
	--build-arg CODESERVER_VER=$env_codeserver_ver \
	--build-arg RSTUDIO_VERSION=$env_rstudio_ver \
	--build-arg DOCKER_VERSION=$env_docker_ver \
	--build-arg DOCKER_COMPOSE_VERSION=$env_docker_compose_ver \
	--build-arg MONGO_VER=$env_mongo_ver \
	--build-arg MODELIO_VER=$env_modelio_ver \
	--build-arg TURBOVNC_VERSION=$env_turbovnc_ver \
	--build-arg JAVA_KERNEL=$java_kernel \
        --build-arg KOTLIN_KERNEL=$kotlin_kernel \
        --build-arg SCALA_KERNEL=$scala_kernel \
        --build-arg TSLABS_KERNEL=$tslabs_kernel \
        --build-arg BASH_KERNEL=$bash_kernel \
	--build-arg ANSIBLE_KERNEL=$ansible_kernel \
        --build-arg PHP_KERNEL=$php_kernel \
	--build-arg XFCE4=$xfc4 \
        --build-arg BRAVE=$brave \
        --build-arg SELENIUM=$selenium \
        --build-arg IDEA=$idea \
        --build-arg PG=$pgadmin \
        --build-arg MYSQL=$mysql \
        --build-arg MONGO=$mongo \
        --build-arg JETTY=$jetty \
        --build-arg JENKINS=$jenkins \
        --build-arg MODELIO=$modelio \
	--build-arg PORTAINER=$portainer \
	--build-arg HEROKU=$heroku \
	--build-arg SONARQUBE=$sonarqube \
        --build-arg TURBOVNC=$turbovnc \
        --build-arg SPICE=$spice \
        --build-arg JUPYTERBOOK=$jupyterbook \
	--build-arg GCP=$gpc \
	--build-arg NETWORK_TOOLS=$network_tools \
	.
#	--no-cache .

exit 0
