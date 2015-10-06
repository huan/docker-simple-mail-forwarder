#!/bin/bash
#
# maintainer: Zhuohuan LI <zixia@zixia.net>
#

OWNER="zixia"
NAME="simple-mail-forwarder"
IMAGENAME="$OWNER/$NAME"

TAG='' && [ -n "$1" ] && TAG=":$1" && shift

CMD="docker run --rm --name $NAME -it ${IMAGENAME}${TAG} shell"

echo ">> Run $CMD"
$CMD
