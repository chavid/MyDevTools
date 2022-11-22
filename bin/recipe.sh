#!/bin/bash

unset DEV_SCRIPTS_DOCKER_TOPDIR
if [ "$1" != "" ] ; then
  DEV_SCRIPTS_DOCKER_TOPDIR=$1
  nbfiles=`find ${DEV_SCRIPTS_DOCKER_TOPDIR} -iregex '.*dockerfile.*' -type f | wc -l `
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
