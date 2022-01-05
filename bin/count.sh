#!/usr/bin/env bash

for i in h cc cpp ;
do find . -name "*.$i" -exec cat {} \;
done | wc -l 


