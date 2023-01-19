#!/bin/bash

Help()
{
   # Display Help
   echo "Start a container from the current selected image."
   echo
   echo "Syntax: run.sh [-u|-h]"
   echo "options:"
   echo "h     Print this Help."
   echo "u     Run with --user $(id -u):$(id -g)."
   echo
}

# Parse the options
while getopts ":hu" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      u) # force rebuilding
         export DEV_SCRIPTS_RUN_USER=on
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
  docker run -p 8888:8888 -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
else
  docker run -p 8888:8888 --user "$(id -u):$(id -g)" -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
fi
