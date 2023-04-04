#!/bin/bash

Help()
{
   # Display Help
   echo "Start a container from the current selected image."
   echo
   echo "Syntax: run.sh [-h|-u|-8|-x]"
   echo "options:"
   echo "h     Print this Help."
   echo "u     Run with --user $(id -u):$(id -g)."
   echo "8     Run with -p 8888:8888."
   echo "x     Run with X11 tunelling."
   echo
}

# Parse the options
while getopts ":hux" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      u) # enforce user id 1000:1000
         export DEV_SCRIPTS_RUN_USER="--user $(id -u):$(id -g)"
         ;;
      x) # forward X11
         xhost + local:docker
         export DEV_SCRIPTS_RUN_X11="-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro"
         ;;
   esac
done

# Find the current recipe
if [ ! -r /tmp/dev-scripts-recipe-dir-$PPID ]
then
  echo unknown recipe
  exit
fi
export DEV_SCRIPTS_DOCKER_DIR=`cat /tmp/dev-scripts-recipe-dir-$PPID`

# Main docker command
docker run --network host ${DEV_SCRIPTS_RUN_X11} ${DEV_SCRIPTS_RUN_USER} -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
#docker run -p 8888:8888 ${DEV_SCRIPTS_RUN_X11} ${DEV_SCRIPTS_RUN_USER} -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
