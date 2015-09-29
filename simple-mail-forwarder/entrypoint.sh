#!/bin/bash

function print_help {
cat <<EOF
        Docker - Simple Mail Forwarder
===============================================

to create a new postfix server for your domain
you should use the following commands:

  docker run -p 25:25 \\
         zixia/simple-mail-forwarder \\
         user1@domain1.com:forward-user1@forward-domain1.com; \\
         user2@domain1.com:forward-user2@forward-domain1.com; \\
         user3@domain2.com:forward-user3@forward-domain2.com; \\
         user4@domain2.com:forward-user4@forward-domain2.com; \\
         userN@domainN.com:forward-userN@forward-domainN.com;

ENV:
    SMF_DOMAIN - mail server hostname. use tutum/docker hostname if omitted.

this creates a new smtp server which listens
on port 25, forward all email from
userN@domainN.com to forward-userN@forward-domainN.com
________________________________________________
by zixia
EOF
}

if [ "-h" == "$1" ] || [ "--help" == "$1" ] || [ -z $1 ] || [ "" == "$1" ]
then
    print_help
    exit 0
fi

if [ ! -f /app/entrypoint.sh ]
then
    >&2 echo ">> you're not inside a valid docker container"
    exit 1;
fi


#
# Set HOSTNAME to right Domain
#
if [ "$SMF_DOMAIN" != "" ] ; then   
    # Defined by User
    HOSTNAME="$SMF_DOMAIN"

elif [ "$TUTUM_CONTAINER_FQDN" != "" ] ; then
    # Defined by Tutum.co
    HOSTNAME="$TUTUM_CONTAINER_FQDN"

elif [ "$TUTUM_NODE_FQDN" != "" ] ; then
    HOSTNAME="$TUTUM_NODE_FQDN"

else
    # Defined by Docker
    HOSTNAME=`hostname`

fi

echo ">> setting up postfix for: $HOSTNAME"


# add domain
postconf -e myhostname="$HOSTNAME"
postconf -e mydestination="$HOSTNAME"
echo "$HOSTNAME" > /etc/mailname
echo "$HOSTNAME" > /etc/hostname
hostname "$HOSTNAME"


#
# Set virtual user maping
#
if [ "$SMF_CONFIG" = "" ]; then
    if [[ "$1" =~ [a-zA-Z0-9_.]+@[a-zA-Z0-9_.]+\. ]]; then                                                                          
        SMF_CONFIG=$1
    else
        echo ">> SMF_CONFIG not found. format: fromUser@fromDomain.com:toUser@toDomain.com;..."
        exit
    fi
fi

NEWLINE=$'\n'

forwardList=(${SMF_CONFIG//;/ })
virtualDomains=""
virtualUsers=""

for forward in "${forwardList[@]}"; do
        emailPair=(${forward//:/ })

        emailFrom=${emailPair[0]}
        emailTo=${emailPair[1]}

        line=$(printf '%s\t%s' $emailFrom $emailTo)
        virtualUsers="$virtualUsers$line$NEWLINE"

        domainFrom=${emailFrom##*@}

        [[ $virtualDomains =~ $domainFrom ]] || {
                virtualDomains="$virtualDomains $domainFrom"
        }
done

echo "$virtualUsers"  > /etc/postfix/virtual

postconf -e virtual_alias_domains="$virtualDomains"
postconf -e virtual_alias_maps="hash:/etc/postfix/virtual"


# initial user database
postmap /etc/postfix/virtual
postfix reload

# starting services
echo ">> starting the services"
service postfix start

# print logs
echo ">> printing the logs"
touch /var/log/mail.log /var/log/mail.err /var/log/mail.warn
chmod a+rw /var/log/mail.*
tail -F /var/log/mail.*
