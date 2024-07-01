ARG JUPYTERHUB_VERSION
FROM jupyterhub/jupyterhub:$JUPYTERHUB_VERSION

RUN apt-get update -y && apt-get install -y apt-transport-https
RUN apt upgrade -y
RUN apt-get install vim -y
RUN apt-get install wget -y
RUN apt-get install apt-utils -y
RUN pip install jupyterhub-idle-culler

RUN /usr/bin/python3 -m pip install --upgrade pip

RUN pip install --no-cache-dir \
        oauthenticator==0.12.* \
        dockerspawner==0.11.* 
RUN apt update && apt install -y ssh
RUN pip install jupyterhub-ltiauthenticator
RUN python3 -m pip install ngshare
COPY jupyterhub_config.py . 
COPY page.html /usr/local/share/jupyterhub/templates/

# ngshare port (default: 10101)
EXPOSE 10101
