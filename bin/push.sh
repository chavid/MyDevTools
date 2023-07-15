#!/bin/bash

#target=${1}
#shift
#flavor=${1}
#shift
#docker run -it --rm -v ${PWD}:/work -w /work `cat ${SCRIPT_DIR}/name.${target}.${flavor}.txt` $*

if [ ! -r /tmp/dev-scripts-recipe-dir-$PPID ]
then
  echo unknown recipe
  exit
fi
export DEV_SCRIPTS_DOCKER_DIR=`cat /tmp/dev-scripts-recipe-dir-$PPID`

docker push `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
docker push latest
