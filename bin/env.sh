
# move to the script directory

SCRIPT_NAME=${BASH_SOURCE[0]}
SCRIPT_DIR=`dirname ${SCRIPT_NAME}`
ORIGINAL_DIR=${PWD}
cd $SCRIPT_DIR

# add script dir to the PATH

SCRIPT_DIR=`pwd`
#export PATH="${SCRIPT_DIR}:${PATH}"

# define current docker recipe

export MY_DEV_TOOLS_DIR=`dirname ${SCRIPT_DIR}`
export MY_DEV_TOOLS_ENV=$1
export MY_DEV_TOOLS_SUBDIR=${MY_DEV_TOOLS_DIR}/${MY_DEV_TOOLS_ENV}

echo env: ${MY_DEV_TOOLS_ENV}

# aliases

alias dbuild=${SCRIPT_DIR}/build.sh
alias dbash=${SCRIPT_DIR}/run.sh

alias count=/mydevtools/count.sh
alias oval=/mydevtools/oval.py

# back to the original directory

cd $ORIGINAL_DIR
