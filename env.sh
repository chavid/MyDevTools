
ORIGINAL_DIR=${PWD}

# establish the script directory absolute path

DEV_SCRIPTS_ENV_FILE=${BASH_SOURCE[0]}
DEV_SCRIPTS_DIR=`dirname ${DEV_SCRIPTS_ENV_FILE}`
cd ${DEV_SCRIPTS_DIR}
DEV_SCRIPTS_DIR=`pwd`
cd ${ORIGINAL_DIR}

# aliases

alias drecipe=${DEV_SCRIPTS_DIR}/bin/recipe.sh
alias dbuild=${DEV_SCRIPTS_DIR}/bin/build.sh
alias drun=${DEV_SCRIPTS_DIR}/bin/run.sh
alias dpush=${DEV_SCRIPTS_DIR}/bin/push.sh

alias drunu=${DEV_SCRIPTS_DIR}/bin/run-user.sh
alias dnvidia=${DEV_SCRIPTS_DIR}/bin/run-nvidia.sh
alias dintel=${DEV_SCRIPTS_DIR}/bin/run-intel.sh

alias count=${DEV_SCRIPTS_DIR}/bin/count.sh
alias oval=${DEV_SCRIPTS_DIR}/bin/oval.py
