#!/bin/bash

set -e

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
export PATH

# run OpenDKIM
/usr/sbin/opendkim -f -l -x /etc/opendkim/opendkim.conf

ret=$?
sleep 1
exit $ret
