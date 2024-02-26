#!/bin/bash

# Find the current recipe
if [ ! -r /tmp/dev-scripts-recipe-dir-$PPID ]
then
  echo unknown recipe
  exit
fi
cat_tmp=`cat /tmp/dev-scripts-recipe-dir-$PPID`
if [[ ${cat_tmp} != /* ]] ; then
  echo turnkey image: ${cat_tmp}
  exit
fi
export DEV_SCRIPTS_DOCKER_DIR=${cat_tmp}

# push
docker push `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
docker push latest
