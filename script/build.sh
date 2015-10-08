#!/bin/bash
#
# maintainer: Zhuohuan LI <zixia@zixia.net>
#

OWNER="zixia"
NAME="simple-mail-forwarder"
IMAGENAME="$OWNER/$NAME"

TAG='' && [ -n "$1" ] && TAG=":$1" && shift

CMD1="docker build -t ${IMAGENAME}${TAG} ."

if [ -n "$CIRCLECI" ]
then
    CMD2="docker run ${IMAGENAME}${TAG} test"
else
    CMD2="docker run --rm --name $NAME ${IMAGENAME}${TAG} test"
fi

echo ">> Run $CMD1"
$CMD1

[ $? -eq 0 ] && {
    echo ">> Run $CMD2"
    $CMD2
}
