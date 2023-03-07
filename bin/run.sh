#!/bin/bash

# The DISPLAY export require you to predefine MYIP
# and is tested only for MacOSX. Having something which
# works also with linux and windows still TO BE DONE.
# So to find your IP number on MacOS, use command
# ifconfig and search for inet lines.

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
while getopts ":hu8x" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      u) # force rebuilding
         export DEV_SCRIPTS_RUN_USER="on"
         ;;
      8) # forward port 8888
         export DEV_SCRIPTS_RUN_8888="-p 8888:8888"
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
if [ -z "${DEV_SCRIPTS_RUN_USER}" ]
then
  docker run ${DEV_SCRIPTS_RUN_8888} ${DEV_SCRIPTS_RUN_X11} -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
else
  docker run ${DEV_SCRIPTS_RUN_8888} ${DEV_SCRIPTS_RUN_X11} --user "$(id -u):$(id -g)" -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
fi
