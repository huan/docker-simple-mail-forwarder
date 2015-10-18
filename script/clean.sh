#!/bin/bash
#
# maintainer: Zhuohuan LI <zixia@zixia.net>
#

OWNER="zixia"
NAME="simple-mail-forwarder"
IMAGE_NAME="$OWNER/$NAME"

TAG='' && [ -n "$1" ] && TAG=":$1" && shift

contList=`docker ps -a -f name=$NAME -f status=exited -q`

echo -n ">> Clean containers... "
if [ -n "$contList" ]
then
    echo -n "Cleaning... "
    xargs docker rm $contList
    echo "Cleaned."
else
    echo "Already clean."
fi


echo -n ">> Clean images... "
imageList=$(docker images -f "dangling=true" -q)
if [ -n "$imageList" ]
then
    echo -n "Cleaning... "
    docker rmi -f $imageList
    echo "Cleaned."
else
    echo "Already clean."
fi

echo ">> Clean all done."
