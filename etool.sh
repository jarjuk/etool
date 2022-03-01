#!/bin/bash

HOST_DIR=tmp/etool
TAG=1
ETOOL="docker run --rm --user $(id -u):$(id -g) -e DISPLAY=unix:0 -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd)/$HOST_DIR:/etool marcus2002/etool:$TAG"

set -x
$ETOOL $*
