#! /bin/sh

set -e

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
export PATH

# guess path for command_directory
command_directory=`postconf -h command_directory`
daemon_directory=`$command_directory/postconf -h daemon_directory`

# kill Postfix if running
$daemon_directory/master -t || $command_directory/postfix stop

# make consistency check
chown root /var/spool/postfix
chown root /var/spool/postfix/pid
$command_directory/postfix check >/dev/console 2>&1

# run Postfix
$daemon_directory/master

ret=$?
sleep 1
exit $ret
