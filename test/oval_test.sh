#!/bin/bash

# so to get the oval alias
source ../env.sh &> /dev/null

# so to make the aliases usable in a non-interactive script
shopt -s expand_aliases

# run the oval command
oval r &> /dev/null
oval d &> oval_test.out

# compare with reference
diff -s oval_test.out oval_test.ref
