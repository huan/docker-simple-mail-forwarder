#!/bin/bash

NAME="zixia/simple-mail-forwarder"

[ -n "$1" ] || {
    echo "Dev Shell must specify a TAG"
    exit 1
}

TAG=":$1" && shift

CMD="docker run --rm -it --entrypoint /bin/bash -v `pwd`:/app.out $NAME$TAG"

echo $CMD && exec $CMD
