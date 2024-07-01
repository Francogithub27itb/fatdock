#ARG IMAGE=jetbrains/projector-idea-u:2021.3-projector-v1.6.0
ARG IMAGE
FROM "${IMAGE}"

USER root
ARG NB_USER
ARG python_major_version=3.9
ENV DEBIAN_FRONTEND="noninteractive" \
    NB_USER="${NB_USER}"

COPY clean-layer.sh /usr/bin/clean-layer.sh
COPY sources.list /sources.list
RUN chmod +x /usr/bin/clean-layer.sh

## setting repos
RUN \
apt update && apt-get install --no-install-recommends gnupg -y && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 && \
#add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse" && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C && \
cp /sources.list /etc/apt/sources.list && rm -f /sources.list && \
clean-layer.sh

RUN apt update && \
    DEBIAN_FRONTEND="noninteractive" apt upgrade -y --option=Dpkg::Options::=--force-confdef && \
    clean-layer.sh

## basics
RUN  apt update -y && \
apt-get install -y --no-install-recommends \
        apt-transport-https \
        gpg \
        gnupg-agent \
        gpg-agent \
        gnupg2 \
        ca-certificates \
        build-essential \
        gfortran \
        gcc \
        pkg-config \
        software-properties-common \
        lsof \
        net-tools \
        libcurl4 \
        curl \
        apt-utils \
        rsync \
        vim \
        iputils-ping \
        ssh \
        plantuml \
        fonts-dejavu \
        git \
        python${python_major_version} \
        python3-tk \
        wget \
        cron \
        openssl \
        iproute2 \
        psmisc \
        tmux \
        dpkg-sig \
        uuid-dev \
        csh \
        xclip \
        clinfo \
        time \
        libssl-dev \
        libgdbm-dev \
        libncurses5-dev \
        libncursesw5-dev \
        # reuired by mysql
        default-libmysqlclient-dev \
        # required by postgres
        libpq-dev \
        # python3-dev \
        # required by pyenv
        libreadline-dev \
        libedit-dev \
        xz-utils \
        # Find files
        locate \
        # Dev Tools
        sqlite3 \
        # XML Utils
        xmlstarlet \
        # GNU parallel
        parallel \
        # Search text and binary files
        yara \
        # Inkscape is installed to be able to convert SVG files
        inkscape \
        # style sheet preprocessor
        less \
        # Print dir tree
        tree \
        # Bash autocompletion functionality
        bash-completion \
        # Map remote ports to localhosM
        socat \
        # Json Processor
        jq \
        rsync \
        # sqlite3 driver - required for pyenv
        libsqlite3-dev \
        # Image support
        libtiff-dev \
        libjpeg-dev \
        libpng-dev \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxext-dev \
        libxrender1 \
        libzmq3-dev \
        libc6-dev libc6 \
        libcrypt1-dev libcrypt1 \
        libpython3.8 \
        libfido2-1 \
        # protobuffer support
        protobuf-compiler \
        libprotobuf-dev \
        libprotoc-dev \
        autoconf \
        automake \
        libtool \
        cmake  \
        fonts-liberation \
        google-perftools \
        # Compression Libs
        # also install rar/unrar? but both are propriatory or unar (40MB)
        zip \
        gzip \
        unzip \
        bzip2 \
        lzop \
        tzdata \
        # nbconvert dependencies
        # https://nbconvert.readthedocs.io/en/latest/install.html#installing-tex
        texlive-xetex \
        texlive-fonts-recommended \
        texlive-plain-generic \
        # deprecates bsdtar (https://ubuntu.pkgs.org/20.04/ubuntu-universe-i386/libarchive-tools_3.4.0-2ubuntu1_i386.deb.html)
        libarchive-tools \
        # zlibc \ obsolete in ubuntu 22.04
        zlibc \
        zlib1g \
        # unpack (almost) everything with one command
        unp \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev \
        sudo && \
apt upgrade -y && \
clean-layer.sh

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-client \
        openssh-server \
        # SSLH for SSH + HTTP(s) Multiplexing
        sslh \
        # SSH Tooling
        autossh \
        sshfs \
        mussh && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Cleanup
    clean-layer.sh

## docker clients
ENV DOCKER_CHANNEL=stable \
        DOCKER_VERSION=20.10.16 \
        DOCKER_COMPOSE_VERSION=2.5.1 \
        DEBUG=false
VOLUME /var/lib/docker

# Docker installation
RUN set -eux; \
        \
        arch="$(uname --m)"; \
        case "$arch" in \
        # amd64
                x86_64) dockerArch='x86_64' ;; \
        # arm32v6
                armhf) dockerArch='armel' ;; \
        # arm32v7
                armv7) dockerArch='armhf' ;; \
        # arm64v8
                aarch64) dockerArch='aarch64' ;; \
                *) echo >&2 "error: unsupported architecture ($arch)"; exit 1 ;;\
        esac; \
        \
        if ! wget -O docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then \
                echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${dockerArch}'"; \
                exit 1; \
        fi; \
        \
        tar --extract \
                --file docker.tgz \
                --strip-components 1 \
                --directory /usr/local/bin/ \
        ; \
        rm docker.tgz; \
        \
        dockerd --version; \
        docker --version && \
        mkdir -p /var/lib/docker && \
        chmod 755 /var/lib/docker && \
        clean-layer.sh

# Docker compose installation
RUN curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose \
&& clean-layer.sh

## mysql client
COPY ./apt-sources/mysql.list /etc/apt/sources.list.d/mysql.list
RUN curl -s http://repo.mysql.com/RPM-GPG-KEY-mysql-2022 | apt-key add - && \
apt update && apt install --no-install-recommends -y default-mysql-client && \
mkdir -p /var/run/mysqld && \
ln -s /var/lib/docker/volumes/mysql_sock/_data/mysqld.sock /var/run/mysqld/mysqld.sock && \
clean-layer.sh
COPY ./mysql.cnf /etc/mysql/conf.d/mysql.cnf

## postgres client
RUN \
apt update && apt install --no-install-recommends -y postgresql-client && \
clean-layer.sh

## mongodb clients
ARG MONGO_VER
RUN \
apt update && \
    if [ "$MONGO_VER" == "4" ]; then \
            asc_ver=4.4 ; \
            shell_ver=4.4.8 ; \
    else \
            asc_ver=5.0 ; \
            shell_ver=5.0.8 ; \
    fi \     
&& apt update && \
curl -fsSL https://www.mongodb.org/static/pgp/server-${asc_ver}.asc | sudo apt-key add - && \
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/${asc_ver} multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-${asc_ver}.list && \
apt update -y && \
apt install --no-install-recommends -y mongodb-org-shell=${shell_ver} mongodb-org-mongos=${shell_ver} mongodb-org-tools=${shell_ver} mongodb-mongosh && \
clean-layer.sh

## conda volume ready
RUN mkdir -p /opt/conda && \
    chown projector-user:100 /opt/conda
VOLUME /opt/conda

## update username
RUN echo "-> NB_USER = ${NB_USER}" && \
    usermod -l ${NB_USER} projector-user && \
    groupmod -g 100 users
RUN mv /home/projector-user /home/$NB_USER && \
    ln -s /home/$NB_USER /home/projector-user && \
    sed -i "s/projector-user/$NB_USER/g" /etc/passwd && \
    groupadd docker && usermod -aG docker $NB_USER
ENV HOME=/home/$NB_USER

USER $NB_USER

