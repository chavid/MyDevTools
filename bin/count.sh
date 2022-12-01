#!/usr/bin/env bash

for i in h hpp hxx c cc cpp cxx py ;
do find . -name "*.$i" -exec cat {} \;
done | wc -l 
