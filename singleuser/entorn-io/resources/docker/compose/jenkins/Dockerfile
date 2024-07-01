FROM jenkins/jenkins:latest-jdk17

USER root

ARG jdk11=microsoft-jdk-11.0.23-linux-x64
ARG jdk17=microsoft-jdk-17.0.11-linux-x64
ARG jdk21=microsoft-jdk-21.0.3-linux-x64
ARG JHOME=/opt/java
ARG MAVEN_VERSION=3.9.8
ARG GRADLE_VERSION=8.8
ARG DOCKER_COMPOSE_VERSION=2.28.1

COPY $jdk11.tar.gz $JHOME/
COPY $jdk17.tar.gz $JHOME/
COPY $jdk21.tar.gz $JHOME/
COPY clean-layer.sh /usr/bin/

RUN chmod +x /usr/bin/clean-layer.sh

## JDKs
RUN \
cd $JHOME && \ 
tar -xzvf $jdk11.tar.gz && \
rm -f $jdk11.tar.gz && \
tar -xzvf $jdk17.tar.gz && \
rm -f $jdk17.tar.gz && \
tar -xzvf $jdk21.tar.gz && \
rm -f $jdk21.tar.gz 
#clean-layer.sh

## Docker
RUN apt-get update && apt-get install -y lsb-release

RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg

RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -y docker-ce-cli

RUN apt update && apt install tzdata -y zip unzip

ENV TZ="Europe/Andorra"

## Maven
ENV M2_HOME=/opt/maven
ENV PATH=${M2_HOME}/bin:${PATH}

RUN \
    curl -fSL "https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" -o apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar -xvzf "apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
    rm -f "apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
    mv "apache-maven-$MAVEN_VERSION" "$M2_HOME" 
RUN \
echo "export JAVA_HOME=$JHOME/openjdk" > /etc/profile.d/maven.sh && \
echo "export M2_HOME=/opt/maven" >> /etc/profile.d/maven.sh && \
echo "export PATH=\${M2_HOME}/bin:\${PATH}" >> /etc/profile.d/maven.sh && \
chmod +x /etc/profile.d/maven.sh

## Docker && docker-compose
RUN \
    curl -sSL https://get.docker.com/ | sh && \
    curl -SL https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose && \
    clean-layer.sh
RUN usermod -aG docker jenkins

## Gradle
ENV GRADLE_HOME=/opt/gradle
ENV PATH=${GRADLE_HOME}/bin:${PATH}
RUN \ 
    cd /tmp && \
    curl -O https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle-*.zip && \
    mkdir -p $GRADLE_HOME && \
    cp -pr gradle-*/* $GRADLE_HOME && \
    clean-layer.sh
RUN \
echo "export PATH=${GRADLE_HOME}/bin:\${PATH}" | tee /etc/profile.d/gradle.sh && \
chmod +x /etc/profile.d/gradle.sh

RUN usermod -aG root jenkins

#RUN rm -rf $JHOME/openjdk && ln -s $JHOME/$jdk17 $JHOME/openjdk

## Back to jenkins user
USER jenkins
RUN echo 'alias ll="ls -alh"' > ~/.bashrc

