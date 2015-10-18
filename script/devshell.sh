#!/bin/bash
#
# maintainer: Zhuohuan LI <zixia@zixia.net>
#

NAME="zixia/simple-mail-forwarder"

[ -n "$1" ] || {
    echo ">> ERROR: Dev Shell must specify a TAG"
    exit 1
}

if [[ $1 =~ : ]]
then
    NAME=${1%%:*}
    TAG=":${1##*:}"
else
    TAG=":$1"
fi

shift # TAG

CMD="docker run --rm --name simple-mail-forwarder -it --entrypoint /bin/bash -v `pwd`:/app.out $NAME$TAG"

echo $CMD && exec $CMD
