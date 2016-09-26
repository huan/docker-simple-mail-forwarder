#!/bin/bash

ENV_FILE=BUILD.env

#
# Get Github info from LOG file
#
RE='^[^ ]+\s+([^ ]+)\s+(.+)\s+<(.+)>\s+([0-9]+)\s+([+-][0-9]{4,4})\s+(.+)$'
[[ `tail -1 GIT_LOG` =~ $RE ]]
hash=${BASH_REMATCH[1]}
author=${BASH_REMATCH[2]}
email=${BASH_REMATCH[3]}
date=${BASH_REMATCH[4]}
tz=${BASH_REMATCH[5]}
log=${BASH_REMATCH[6]##*commit: }

## fix strange timezone XXX
if [[ $tz =~ \+ ]] 
then
    tz_tmp=${tz//+/-}
else
    tz_tmp=${tz//-/+}
fi

## generate date string for human
date=`TZ=$tz_tmp awk '{ print strftime("%c", $0); }' <<< $date`
date="$date $tz"

## get source branch
read branch < GIT_HEAD
branch=${branch##*/}

## short hash as github, lentgh: 7
hash=${hash:0:7}

## get IP
RE='[0-9]+\s+IN\s+A\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)'
[[ `drill SimpleMailForwarder.Builder.\`hostname\` @wimi.36c33f49.svc.dockerapp.io` =~ $RE ]] \
        && SMF_BUILD_IP="${BASH_REMATCH[1]}"

#
# Save to file
#
cat >> $ENV_FILE <<_EOF
SMF_BUILD_DATE='`date`'
SMF_BUILD_HOST='`hostname`'
SMF_BUILD_IP='$SMF_BUILD_IP'

GIT_BRANCH='$branch'
GIT_HASH='$hash'
GIT_DATE='$date'
GIT_AUTHOR='$author'
GIT_EMAIL='$email'
GIT_LOG='$log'
_EOF

