#!/bin/bash

RESOURCES=/resources
CONDA_BASE_PATH=/opt/conda
KERNELS_DIR=$CONDA_BASE_PATH/share/jupyter/kernels

# python
sed -i 's/"Python 3 (ipykernel)"/"Python 3"/g'   $CONDA_BASE_PATH/share/jupyter/kernels/python3/kernel.json

# tslab
sed -i "s|tslab|$CONDA_BASE_PATH/share/npm-packages/bin/tslab|g" $CONDA_BASE_PATH/share/jupyter/kernels/tslab/kernel.json && \
sed -i "s|tslab|$CONDA_BASE_PATH/share/npm-packages/bin/tslab|g" $CONDA_BASE_PATH/share/jupyter/kernels/jslab/kernel.json && \
mv $CONDA_BASE_PATH/share/jupyter/kernels/jslab $CONDA_BASE_PATH/share/jupyter/kernels/javascript && \
mv $CONDA_BASE_PATH/share/jupyter/kernels/tslab $CONDA_BASE_PATH/share/jupyter/kernels/typescript

## logos

[ -d "$CONDA_BASE_PATH/share/jupyter/kernels/java" ] && cp $RESOURCES/logos/java/* $CONDA_BASE_PATH/share/jupyter/kernels/java/

[ -d "$CONDA_BASE_PATH/share/jupyter/kernels/javascript" ] && cp $RESOURCES/logos/js/* $CONDA_BASE_PATH/share/jupyter/kernels/javascript/

[ -d "$CONDA_BASE_PATH/share/jupyter/kernels/typescript" ] && cp $RESOURCES/logos/ts/* $CONDA_BASE_PATH/share/jupyter/kernels/typescript/

[ -d "$CONDA_BASE_PATH/share/jupyter/kernels/imongo" ] && cp $RESOURCES/logos/imongo/* $CONDA_BASE_PATH/share/jupyter/kernels/imongo/

#[ -d "$CONDA_BASE_PATH/share/jupyter/kernels/ansible" ] && cp $RESOURCES/logos/ansible/* $CONDA_BASE_PATH/share/jupyter/kernels/ansible/

[ -d "$CONDA_BASE_PATH/share/jupyter/kernels/calysto_bash" ] && cp $RESOURCES/logos/bash/* $CONDA_BASE_PATH/share/jupyter/kernels/calysto_bash/

[ -d "$CONDA_BASE_PATH/share/jupyter/kernels/calysto_bash" ] && sed -i 's/"display_name": "Calysto Bash"/"display_name":"Bash"/g' $KERNELS_DIR/calysto_bash/kernel.json

[ -d "$CONDA_BASE_PATH/share/jupyter/kernels/php" ] && cp $RESOURCES/logos/php/* $CONDA_BASE_PATH/share/jupyter/kernels/php/

exit 0

