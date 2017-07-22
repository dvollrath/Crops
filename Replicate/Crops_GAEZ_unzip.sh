#!/bin/bash

cd /users/dietz/dropbox/crops/data/gaez

# For each type of file, extract only the TIF data file

# Extract GAEZ crop suitability indices
for x in res03crav6190lsxlr*_package.zip
do
    unzip -o $x \*.tif
done

# Extract GAEZ soil conditions
for x in lrsoisq*mze_package.zip
do
    unzip -o $x \*.tif
done

# Extract GAEZ agro-climatic conditions
for x in res01*crav6190_package.zip
do
    unzip -o $x \*.tif
done