#!/bin/bash

NAME="zixia/simple-mail-forwarder"
TAG=''
[ -n "$1" ] && TAG=":$1" && shift

CMD="docker run --rm -it $NAME$TAG shell"

echo $CMD
$CMD
