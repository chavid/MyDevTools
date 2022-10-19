
ORIGINAL_DIR=${PWD}

# establish the script directory absolute path

DEV_SCRIPTS_ENV_FILE=${BASH_SOURCE[0]}
DEV_SCRIPTS_DIR=`dirname ${DEV_SCRIPTS_ENV_FILE}`
cd ${DEV_SCRIPTS_DIR}
DEV_SCRIPTS_DIR=`pwd`
cd ${ORIGINAL_DIR}

# aliases

alias dbuild=${DEV_SCRIPTS_DIR}/bin/build.sh
alias dbash=${DEV_SCRIPTS_DIR}/bin/run.sh
alias dpush=${DEV_SCRIPTS_DIR}/bin/push.sh

alias count=${DEV_SCRIPTS_DIR}/bin/count.sh
alias oval=${DEV_SCRIPTS_DIR}/bin/oval.py

# look for a docker recipe

unset DEV_SCRIPTS_DOCKER_DIR
if [ "$1" != "" ] ; then
  if [ -f "$1/Dockerfile" ] ; then
    cd $1
    export DEV_SCRIPTS_DOCKER_DIR=`pwd`
    cd ${ORIGINAL_DIR}
  else
    if [ -f "${DEV_SCRIPTS_DIR}/$1/Dockerfile" ] ; then
      export DEV_SCRIPTS_DOCKER_DIR=${DEV_SCRIPTS_DIR}/$1
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
      export DEV_SCRIPTS_DOCKER_DIR=`dirname ${dockerfile}`
      cd ${DEV_SCRIPTS_DOCKER_DIR}
      export DEV_SCRIPTS_DOCKER_DIR=`pwd`
      cd ${ORIGINAL_DIR}
    fi
  fi
fi
if [ -n "${DEV_SCRIPTS_DOCKER_DIR}" ] ; then
  echo recipe: ${DEV_SCRIPTS_DOCKER_DIR}/Dockerfile
fi
