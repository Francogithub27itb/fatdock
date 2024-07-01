#!/bin/bash

RESOURCES_PATH=/resources

mkdir -p /usr/local/bin/start-notebook.d/
mkdir -p /usr/local/bin/before-notebook.d/

\cp $RESOURCES_PATH/bin-hooks/start-custom.sh /usr/local/bin/start-notebook.d/
\cp $RESOURCES_PATH/bin-hooks/before-custom.sh /usr/local/bin/before-notebook.d/

