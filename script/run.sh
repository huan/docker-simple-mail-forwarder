#!/bin/bash
#
# maintainer: Zhuohuan LI <zixia@zixia.net>
#

NAME="zixia/simple-mail-forwarder"
TAG='' && [ -n "$1" ] && TAG=":$1" && shift

CMD="docker run ${NAME}${TAG} $@"

echo ">> $CMD"
$CMD
