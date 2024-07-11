#!/bin/bash

echo "Installing BIO libraries for python ..."
echo

## BIO
#mamba install biopython -y

echo "Installing R dependencies ..."
echo

## R
mamba install -n base --quiet --yes \
    'r-base' \
    'r-ggplot2' \
    'r-irkernel' \
    'r-rcurl' \
    'r-sparklyr'

mamba install -c conda-forge --strict-channel-priority -y r-arrow
mamba install -c conda-forge pyarrow
#mamba install -n base -c bioconda -y bioconductor-biobase

exit 0
