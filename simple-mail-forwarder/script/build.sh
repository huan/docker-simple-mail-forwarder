#!/bin/bash

NAME="zixia/simple-mail-forwarder"
TAG='' && [ -n "$1" ] && TAG=":$1" && shift

CMD1="docker build -t $NAME$TAG ."
CMD2="docker run $NAME$TAG test"

echo ">> $CMD1"
$CMD1

[ $? -eq 0 ] && {
    echo ">> $CMD2"
    $CMD2
}
