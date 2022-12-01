#!/bin/bash

if [ ! -r /tmp/dev-scripts-recipe-dir-$PPID ]
then
  echo unknown recipe
  exit
fi
export DEV_SCRIPTS_DOCKER_DIR=`cat /tmp/dev-scripts-recipe-dir-$PPID`

# Pour que sycl-ls voit l'iGPU, il faut --privileged, et apparemment laisser le user root
# Par ailleurs, selon :
#   https://www.intel.com/content/www/us/en/develop/documentation/get-started-with-intel-oneapi-base-linux/top/using-containers/using-containers-with-the-command-line.html
# Il faudrait --device=/dev/dri, mais je n'ai pas vu d'effet : d'apres un gars d'intel, --device=/dev/dri peut etre indispensable
# pour certaines applications (un simple sycl-ls ne teste que peu de choses). Lui-même met carrément -v /dev:/dev .

docker run --privileged -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
