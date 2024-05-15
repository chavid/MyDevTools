#!/usr/bin/env bash

# Init env
__conda_setup="$('/home/dev/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/dev/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/dev/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/dev/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# Eval

eval $*

