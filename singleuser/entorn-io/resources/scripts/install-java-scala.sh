#!/bin/bash

# Enable exit on error
set -e
# Show all commands
set -x

SDKMAN_DIR="/opt/sdkman"

echo ""
echo "Installing runtime for java, scala..."
echo "Java version = ${JAVA_VERSION}-${JAVA_PROVIDER}"
echo "Scala version = ${SCALA3_VER}"
echo ""

curl -s "https://get.sdkman.io" | bash 
source "$SDKMAN_DIR/bin/sdkman-init.sh"
sdk install java ${JAVA_VERSION}-${JAVA_PROVIDER}
chown $NB_USER:$NB_GID -R $SDKMAN_DIR
if [[ ! -z "$SCALA3_VER" ]]; then
   sdk install scala ${SCALA3_VER} ; 
   sdk install sbt ;
fi

sdk install maven
sdk install gradle

exit 0
