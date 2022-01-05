
# move to the script directory

SCRIPT_NAME=${BASH_SOURCE[0]}
SCRIPT_DIR=`dirname ${SCRIPT_NAME}`
ORIGINAL_DIR=${PWD}
cd $SCRIPT_DIR

# add script dir to the PATH

SCRIPT_DIR=`pwd`
export PATH="${SCRIPT_DIR}:${PATH}"

# define current docker recipe

MAIN_DIR=`dirname ${SCRIPT_DIR}`
export MY_DOCKER_ENV=$1
echo MY_DOCKER_ENV: ${MY_DOCKER_ENV}
export MY_DOCKER_SUBDIR=${MAIN_DIR}/${MY_DOCKER_ENV}

# aliases

alias dbuild=build.sh
alias drun=run.sh
alias count=count.sh

# back to the original directory

cd $ORIGINAL_DIR
