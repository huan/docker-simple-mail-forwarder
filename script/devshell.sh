#!/bin/bash
#
# maintainer: Zhuohuan LI <zixia@zixia.net>
#

NAME="zixia/simple-mail-forwarder"

[ -n "$1" ] || {
    echo ">> ERROR: Dev Shell must specify a TAG"
    exit 1
}

TAG=":$1" && shift

CMD="docker run --rm --name simple-mail-forwarder -it --entrypoint /bin/bash -v `pwd`:/app.out $NAME$TAG"

echo $CMD && exec $CMD
