#!/bin/bash

#target=${1}
#shift
#flavor=${1}
#shift
#docker run -it --rm -v ${PWD}:/work -w /work `cat ${SCRIPT_DIR}/name.${target}.${flavor}.txt` $*

docker push `cat ${MY_DEV_TOOLS_DOCKER_DIR}/Dockertag`
