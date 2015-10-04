#!/bin/bash
#
# maintainer: Zhuohuan LI <zixia@zixia.net>
#

cat <<_BANNER
 ______      _          ____            
|__  (_)_  _(_) __ _   | __ )  _____  __
  / /| \\ \\/ / |/ _\` |  |  _ \\ / _ \\ \\/ /
 / /_| |>  <| | (_| |  | |_) | (_) >  < 
/____|_/_/\\_\\_|\\__,_|  |____/ \\___/_/\\_\\


_BANNER

ARGV=$@

echo "$(hostname -i) box box.zixia.net" >> /etc/hosts

echo ">> ARGV [$ARGV]"
echo ">> ARGV# [${#@}]"

if [ "" == "$ARGV" ]
then
    service rsyslog start
    service sshd start
    exec /sbin/init
else
    exec $@
fi

echo 

