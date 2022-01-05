#!/bin/bash

#target=${1}
#shift
#flavor=${1}
#shift
#docker run -it --rm -v ${PWD}:/work -w /work `cat ${SCRIPT_DIR}/name.${target}.${flavor}.txt` $*

docker run -it --rm -v ${PWD}:/work -w /work `cat ${MY_DOCKER_SUBDIR}/image.txt` $*
