#!/bin/bash

# Establish top DevScripts dir
DEV_SCRIPTS_ENV_FILE=${BASH_SOURCE[0]}
DEV_SCRIPTS_BIN_DIR=`dirname ${DEV_SCRIPTS_ENV_FILE}`
DEV_SCRIPTS_DIR=`dirname ${DEV_SCRIPTS_BIN_DIR}`

Help()
{
   # Display Help
   echo
   echo "Search for a recipe."
   echo
   echo "Syntax: recipe.sh [-v|-h] [directory]"
   echo "options:"
   echo "h     Print this Help."
   echo "v     Show the currently selected recipe."
   echo
}

# Parse the options
while getopts ":hvi" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      i) # take a turnkey image
         shift
         turnkey="true"
         ;;
      v) # verbose
         if [ ! -r /tmp/dev-scripts-recipe-dir-$PPID ]
         then
           echo unknown recipe
           exit
         fi
         cat /tmp/dev-scripts-recipe-dir-$PPID
         exit;;
   esac
done

if [[ -v turnkey ]]
then
  echo $1 &> /tmp/dev-scripts-recipe-dir-$PPID
  echo recipe: `cat /tmp/dev-scripts-recipe-dir-$PPID`
  exit
fi

unset DEV_SCRIPTS_DOCKER_TOPDIR
nbfiles=0
if [ "$1" != "" ] ; then
  if [ -d "$1" ] ; then
    DEV_SCRIPTS_DOCKER_TOPDIR=$1
    nbfiles=`find ${DEV_SCRIPTS_DOCKER_TOPDIR} -iregex '.*dockerfile.*' -type f | wc -l `
  fi
  if [ ${nbfiles} -eq 0 ] ; then
    if [[ ${1} != /* ]] ; then
      DEV_SCRIPTS_DOCKER_TOPDIR=${DEV_SCRIPTS_DIR}/${1}
      nbfiles=`find ${DEV_SCRIPTS_DOCKER_TOPDIR} -iregex '.*dockerfile.*' -type f | wc -l `
    fi
  fi
else
  DEV_SCRIPTS_DOCKER_TOPDIR="."
  nbfiles=`find ${DEV_SCRIPTS_DOCKER_TOPDIR} -iregex '.*dockerfile.*' -type f | wc -l `
  if [ ${nbfiles} -eq 0 ] ; then
    DEV_SCRIPTS_DOCKER_TOPDIR=${DEV_SCRIPTS_DIR}
    nbfiles=`find ${DEV_SCRIPTS_DOCKER_TOPDIR} -iregex '.*dockerfile.*' -type f | wc -l `
  fi
fi

if [ ${nbfiles} -gt 1 ] ; then
  echo multiple recipes found
elif [ ${nbfiles} -eq 0 ] ; then
  echo no recipe found
else
  DOCKERFILE=`find ${DEV_SCRIPTS_DOCKER_TOPDIR} -iregex '.*dockerfile.*' -type f`
  ORIGINAL_DIR=${PWD}
  cd `dirname ${DOCKERFILE}`
  echo `pwd` &> /tmp/dev-scripts-recipe-dir-$PPID
  cd ${ORIGINAL_DIR}
  echo recipe: `cat /tmp/dev-scripts-recipe-dir-$PPID`
fi
