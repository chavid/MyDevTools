#!/bin/bash

#target=${1}
#shift
#flavor=${1}
#shift

cd ${MY_DEV_TOOLS_SUBDIR}

rm -rf mydevtools
cp -r ../bin mydevtools

docker build  -f Dockerfile -t `cat image.txt` .
# --force-rm --no-cache