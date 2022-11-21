#!/bin/bash

#target=${1}
#shift
#flavor=${1}
#shift
#docker run --user "$(id -u):$(id -g)" -it --rm -v ${PWD}:/work -w /work `cat ${SCRIPT_DIR}/name.${target}.${flavor}.txt` $*

docker run --user "$(id -u):$(id -g)" -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
