#!/bin/bash

Help()
{
   # Display Help
   echo "Start a container from the current selected image."
   echo
   echo "Syntax: run.sh [-h|-u|-8]"
   echo "options:"
   echo "h     Print this Help."
   echo "u     Run with --user $(id -u):$(id -g)."
   echo "8     Run with -p 8888:8888."
   echo
}

# Parse the options
while getopts ":hu8" option; do
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
  docker run ${DEV_SCRIPTS_RUN_8888} -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
else
  docker run ${DEV_SCRIPTS_RUN_8888} --user "$(id -u):$(id -g)" -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
fi
