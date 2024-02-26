#!/bin/bash

# The options `-p 8888:8888` and similar are made useless by the
# `--network host` option.

# For GPUS, the options `--privileged` and `--device=/dev/dri`
# are made useless by the `--gpus all` option.
# ... but --gpus all breaks a simple hello world for gcc 13 ?!?
# https://github.com/docker-library/gcc/issues/99

Help()
{
   # Display Help
   echo "Start a container from the current selected image."
   echo
   echo "Syntax: run.sh [-h|-u|-8|-x|-r]"
   echo "options:"
   echo "h     Print this Help."
   echo "u     Run with --user $(id -u):$(id -g)."
   echo "8     Run with -p 8888:8888."
   echo "x     Run with X11 tunelling."
   echo "g     Run with --gpus all."
   echo "r     Use an explicit image rather than the default one."
   echo
}

# Find the optional current recipe and deduce the image name

if [ -r /tmp/dev-scripts-recipe-dir-$PPID ]
then
  cat_tmp=`cat /tmp/dev-scripts-recipe-dir-$PPID`
  if [[ ${cat_tmp} == /* ]] ; then
    DEV_SCRIPTS_DOCKER_DIR=${cat_tmp}
    image=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
  else
    image=${cat_tmp}
  fi
fi

# Parse the options

while getopts ":hu8xg" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      u) # enforce user id 1000:1000
         shift
         export DEV_SCRIPTS_RUN_USER="--user $(id -u):$(id -g)"
         ;;
      8) # forward port 8888
         shift
         export DEV_SCRIPTS_RUN_8888="-p 8888:8888"
         ;;
      x) # forward X11
         shift
         xhost + local:docker
         export DEV_SCRIPTS_RUN_X11="-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro"
         ;;
      g) # GPUs
         shift
         export DEV_SCRIPTS_RUN_GPUS="--gpus all"
         ;;
   esac
done

# Finalize image choice

if [[ -v ignorerecipe ]]
then
  image=$1
  shift
fi
if [[ ! -v image ]]
then
  echo "No image specified with -r and no recipe selected."
  exit
fi

# Main docker command

docker run --network host ${DEV_SCRIPTS_RUN_GPUS} ${DEV_SCRIPTS_RUN_8888} ${DEV_SCRIPTS_RUN_X11} ${DEV_SCRIPTS_RUN_USER} -it --rm -v ${PWD}:/work -w /work -e DTAG=${image} ${image} $*
