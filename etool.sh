#!/bin/bash

TAG=4
# Changes this to choose correct version
ETOOL_DIR=$HOME/.etool

[ -d  $ETOOL_DIR ] || ( mkdir $ETOOL_DIR && echo Created ETOOL_DIR=$ETOOL_DIR )

ETOOL="docker run --rm --user $(id -u):$(id -g) -e DISPLAY=unix:0 -v /tmp/.X11-unix:/tmp/.X11-unix -v $ETOOL_DIR:/etool marcus2002/etool:$TAG"

set -x
$ETOOL $*
