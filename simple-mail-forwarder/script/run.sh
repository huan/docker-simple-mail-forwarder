#!/bin/bash

NAME="zixia/simple-mail-forwarder"
TAG=''

[ -n "$1" ] && TAG=":$1" && shift

echo "docker run -it $NAME$TAG $@"
docker run -it $NAME$TAG $@
