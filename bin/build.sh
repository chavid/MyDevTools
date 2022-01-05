#!/bin/bash

#target=${1}
#shift
#flavor=${1}
#shift

cd ${MY_DOCKER_SUBDIR}
docker build  -f Dockerfile -t `cat image.txt` .
# --force-rm --no-cache