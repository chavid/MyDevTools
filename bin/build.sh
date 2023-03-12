#!/bin/bash

Help()
{
   # Display Help
   echo "Build an image from the current selected recipe."
   echo
   echo "Syntax: build.sh [-f|-h]"
   echo "options:"
   echo "h     Print this Help."
   echo "f     Build with --force-rm --no-cache."
   echo
}

# Parse the options
while getopts ":hf" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      f) # force rebuilding
         export DEV_SCRIPTS_BUILD_FORCE=on
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

# Prepare data to be eventually copied in the image
cd ${DEV_SCRIPTS_DOCKER_DIR}
rm -rf mydevtools
cp -r ${DEV_SCRIPTS_DIR}/bin mydevtools

# Main docker command
if [ -z "${DEV_SCRIPTS_BUILD_FORCE}" ]
then
  docker build --build-arg GROUP_ID="$(id -g)" --build-arg USER_ID="$(id -u)" -f Dockerfile -t `cat Dockertag` .
else
  docker build --build-arg GROUP_ID="$(id -g)" --build-arg USER_ID="$(id -u)" --force-rm --no-cache -f Dockerfile -t `cat Dockertag` .
fi
