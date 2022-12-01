#!/bin/bash

if [ ! -r /tmp/dev-scripts-recipe-dir-$PPID ]
then
  echo unknown recipe
  exit
fi
export DEV_SCRIPTS_DOCKER_DIR=`cat /tmp/dev-scripts-recipe-dir-$PPID`

# Côté hôte, il faut avoir installer une extension NVidia.
# Par exemple, sur ubuntu 22.04 : `apt install nvidia-docker2`.
# Une des difficulté que je ne maitrise pas : il faut avoir la meme version
# de "driver" entre hôte et conteneur.
# Pour utiliser l'image oneapi basée sur ubuntu 20.4, en latest,
# j'ai du installer sur l´hôte nvidia-driver-520

docker run --gpus all --user "$(id -u):$(id -g)" -it --rm -v ${PWD}:/work -w /work -e DTAG=`cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag` `cat ${DEV_SCRIPTS_DOCKER_DIR}/Dockertag`
