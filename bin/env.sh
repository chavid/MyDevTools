
ORIGINAL_DIR=${PWD}

# establish the script directory absolute path

SCRIPT_NAME=${BASH_SOURCE[0]}
SCRIPT_DIR=`dirname ${SCRIPT_NAME}`
cd ${SCRIPT_DIR}
SCRIPT_DIR=`pwd`
cd ${ORIGINAL_DIR}

# aliases

alias dbuild=${SCRIPT_DIR}/build.sh
alias dbash=${SCRIPT_DIR}/run.sh
alias dpush=${SCRIPT_DIR}/push.sh

alias count=${SCRIPT_DIR}/count.sh
alias oval=${SCRIPT_DIR}/oval.py

# look for a docker recipe

unset MY_DEV_TOOLS_DOCKER_DIR
if [ "$1" != "" ] ; then
  if [ -f "$1/Dockerfile" ] ; then
    export MY_DEV_TOOLS_DOCKER_DIR=$1
  else
    MY_DEV_TOOLS_DIR=`dirname ${SCRIPT_DIR}`
    if [ -f "${MY_DEV_TOOLS_DIR}/$1/Dockerfile" ] ; then
      export MY_DEV_TOOLS_DOCKER_DIR=${MY_DEV_TOOLS_DIR}/$1
    else
      echo recipe not found
    fi
  fi
else
  nbfiles=`find . -iregex '.*dockerfile.*' -type f | wc -l `
  if [ ${nbfiles} -gt 1 ] ; then
    echo multiple recipes found
  else
    if [ ${nbfiles} -eq 0 ] ; then
      echo no recipe found
    else
      dockerfile=`find . -iregex '.*dockerfile.*' -type f`
      MY_DEV_TOOLS_DOCKER_DIR=`dirname ${dockerfile}`
      cd ${MY_DEV_TOOLS_DOCKER_DIR}
      MY_DEV_TOOLS_DOCKER_DIR=`pwd`
      cd ${ORIGINAL_DIR}
    fi
  fi
fi
if [ -n "${MY_DEV_TOOLS_DOCKER_DIR}" ] ; then
  echo recipe: ${MY_DEV_TOOLS_DOCKER_DIR}/Dockerfile
fi
