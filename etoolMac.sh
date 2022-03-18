#!/bin/bash

ETOOL_DIR=$HOME/.etool
# Changes this to choose correct version
TAG=3

[ -d  $ETOOL_DIR ] || ( mkdir $ETOOL_DIR && echo Created ETOOL_DIR=$ETOOL_DIR )

# export IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
# xhost +$IP
# xhost +

ETOOL="docker run --rm --user $(id -u):$(id -g) -e DISPLAY=docker.for.mac.host.internal:0 -e XAUTHORITY=/.Xauthority --net host -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/.Xauthority  -v $ETOOL_DIR:/etool marcus2002/etool:$TAG"

set -x
$ETOOL $*
