#!/bin/bash
#
# maintainer: Zhuohuan LI <zixia@zixia.net>
#

OWNER="zixia"
NAME="simple-mail-forwarder"
IMAGE_NAME="$OWNER/$NAME"

TAG='' && [ -n "$1" ] && TAG=":$1" && shift

BASEDIR=$(dirname $0)
ENV_FILE=$BASEDIR/../BUILD.env

RE='[0-9]+\s+IN\s+A\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)'
[[ `drill SimpleMailForwarder.Builder.\`hostname\` @wimi.36c33f49.svc.dockerapp.io` =~ $RE ]] && {
    SMF_BUILD_IP="${BASH_REMATCH[1]}"
}

cat > $ENV_FILE <<_EOF
IMAGE_NAME=$IMAGE_NAME
TAG=${TAG##:}

SMF_BUILD_DATE='`date`'
SMF_BUILD_HOST='`hostname`'
SMF_BUILD_IP='$SMF_BUILD_IP'

GIT_BRANCH='`git branch | cut -d' ' -f2`'
GIT_HASH='`git log -1 --format=%h`'
GIT_DATE='`git log -1 --format=%cd`'
GIT_AUTHOR='`git log -1 --format=%cn`'
GIT_EMAIL='`git log -1 --format=%ce`'
GIT_LOG='`git log -1 --format=%s`'
_EOF

CMD1="docker build -t ${IMAGE_NAME}${TAG} ."

if [ -n "$CIRCLECI" ]
then
    # do not use --rm param inside circleCI
    CMD2="docker run ${IMAGE_NAME}${TAG} test"
else
    CMD2="docker run --rm --name $NAME ${IMAGE_NAME}${TAG} test"
fi

echo ">> Run $CMD1"
$CMD1

[ $? -eq 0 ] && {
    echo ">> Run $CMD2"
    $CMD2
}
