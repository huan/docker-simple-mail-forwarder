#!/bin/bash
ARGV=$@

function print_help {
cat <<EOF
                Docker SMF - Simple Mail Forwarder
===============================================================================
To create a new mail server for your domain,
you could use the following commands:

$ docker run -p 25:25 \\
    zixia/simple-mail-forwarder \\
    user1@domain1.com:forward-user1@forward-domain1.com; \\
    user2@domain1.com:forward-user2@forward-domain1.com; \\
    userN@domainN.com:forward-userN@forward-domainN.com;

Environment Variables:
    SMF_DOMAIN - mail server hostname. use tutum/docker hostname if omitted.
    SMF_CONFIG - mail forward addresses mapping list.
    SMF_MYNETWORKS - configure relaying from trusted IPs, see http://www.postfix.org/postconf.5.html#mynetworks
    SMF_RELAYHOST - configure a relayhost
    SMF_SENDERPRIVACY - strips sender's IP, client, and user agent.

this creates a new smtp server which listens on port 25,
forward all email from
userN@domainN.com to forward-userN@forward-domainN.com
_______________________________________________________________________________

EOF
}

#
# Start
#
function start_postfix {
    #
    # OpenSSL Init
    #
    bash /app/init-openssl.sh

    #
    # Set virtual user maping
    #
    if [ "$SMF_CONFIG" = "" ]; then
        if [[ "$1" =~ [a-zA-Z0-9_.]+@[a-zA-Z0-9_.]+\. ]]; then
            SMF_CONFIG=$1
        else
            echo ">> SMF_CONFIG not found. format: fromUser@fromDomain.com:toUser@toDomain.com;..."
            echo ">> I don't know how to do. So I quit."
            exit
        fi
    else
    	echo ">> SMF_CONFIG found in ENV. use this settings for forward maps."
    fi

    echo "SMF_CONFIG='$SMF_CONFIG'" > SMF_CONFIG.env

    NEWLINE=$'\n'

    # seperated by ;, or "\n" also supported(for config file in the furture).
    forwardList=(${SMF_CONFIG//;/ })

    virtualDomains=""
    virtualUsers=""

    password='' # global variable for save password in the next for loop.

    for forward in "${forwardList[@]}"; do
        emailPair=(${forward//:/ })

        emailFrom=${emailPair[0]}
        emailTo=${emailPair[1]}
        emailToArr=(${emailTo//|/ })
        emailTo=$(printf "\t%s" "${emailToArr[@]}")
        emailTo=${emailTo:1}
        tryPassword=${emailPair[2]}

        # 1. if user has no password, then use the last seen password from other users.
        # 2. if there's no password defined at all, random generate one for the first time.
        if [ -z "$tryPassword" ]
        then
            if [ -z "$password" ]
            then
                # random generate password
                password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1 | tr '[:upper:]' '[:lower:]')
            fi
            tryPassword=$password
        fi

        password=$tryPassword

        echo ">> Setting password[$password] for user $emailFrom ..."
        echo $password | saslpasswd2 $emailFrom

        newLine=$(printf '%s\t%s' $emailFrom "$emailTo")
        virtualUsers="${virtualUsers}${newLine}${NEWLINE}"

        domainFrom=${emailFrom##*@}

        [[ $virtualDomains =~ $domainFrom ]] || {
            virtualDomains="$virtualDomains $domainFrom"
        }
    done

    #
    # issue #1: forward all other emails to the original domain
    #
    for virtualDomain in $virtualDomains; do
      virtualUsers="${virtualUsers}@${virtualDomain} @${virtualDomain} $NEWLINE"
    done

    echo "$virtualUsers"  > /etc/postfix/virtual

    # issue #1: postconf -e virtual_alias_domains="$virtualDomains"
    postconf -e relay_domains="$virtualDomains"
    postconf -e virtual_alias_maps="hash:/etc/postfix/virtual"

    # initial user database
    postmap /etc/postfix/virtual


    #
    # Set HOSTNAME to right Domain
    #
    if [ "$SMF_DOMAIN" != "" ]
    then
        # get from user setting
        HOSTNAME="$SMF_DOMAIN"
    elif [ "$TUTUM_CONTAINER_FQDN" != "" ]
    then
        # use tutum.co FQDN for this container
        HOSTNAME="$TUTUM_CONTAINER_FQDN"
    elif [ "$TUTUM_NODE_FQDN" != "" ]
    then
        # use tutum.co FQDN for this node
        HOSTNAME="$TUTUM_NODE_FQDN"
    elif [ "$domainFrom" != "" ]
    then
        # use the last virtual domain name
        HOSTNAME=$domainFrom
    elif [[ "`hostname`" =~ ^[a-zA-Z0-9_.]+\.[a-zA-Z0-9_.]+ ]]
    then
        # this docker has a valid FQDN hostname!
        HOSTNAME=`hostname`
    else
        # bad! whatever get from Docker
        HOSTNAME=`hostname`
    fi

    # this one is not posix compatible: RE='\d+\s+IN\s+A\s+(\d+\.\d+\.\d+\.\d+)'
    # use next one: [0-9] for \d , make posix comfortable (I will not :-[ )
    RE='[0-9]+\s+IN\s+A\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)'
    [[ `drill SimpleMailForwarder.smf.$HOSTNAME @wimi.36c33f49.svc.dockerapp.io` =~ $RE ]] && {
        # Setting hosts
        HOSTS_LINE="${BASH_REMATCH[1]}\t$HOSTNAME"
        grep -v $HOSTS_LINE /etc/hosts | grep -v ^$ > /etc/hosts.$$
        cat /etc/hosts.$$ > /etc/hosts && rm /etc/hosts.$$
        echo -e $HOSTS_LINE >> /etc/hosts
    }

    echo "SMF_DOMAIN='$HOSTNAME'" > SMF_DOMAIN.env

    echo ">> Set hostname to $HOSTNAME"

    if [ "$SMF_MYNETWORKS" != "" ]
    then
        postconf -e mynetworks="$SMF_MYNETWORKS"
    fi

    # add domain
    postconf -e myhostname="$HOSTNAME"
    postconf -e mydestination="localhost"
    echo "$HOSTNAME" > /etc/mailname
    echo "$HOSTNAME" > /etc/hostname

    if [ "$SMF_RELAYHOST" != "" ]
    then
        postconf -e relayhost="$SMF_RELAYHOST"
    fi

    if [ "$SMF_RELAYAUTH" != "" ]
    then
        echo "$SMF_RELAYHOST   $SMF_RELAYAUTH" > /etc/postfix/sasl_passwd
        postmap /etc/postfix/sasl_passwd
        postconf -e smtp_use_tls=yes
        postconf -e smtp_sasl_auth_enable=yes
        postconf -e smtp_sasl_security_options=
        postconf -e smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd
        postconf -e smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
    fi

    if [ "$SMF_SENDERPRIVACY" != "" ]
    then
        echo "Stripping sender's IP, client, and user agent."
        postconf -e smtp_header_checks=pcre:/etc/postfix/sender_header_filter.pcre
    fi

    postfix start

    # migrating older single-domain DKIM (/var/db/dkim/default.*) to /var/db/dkim/$HOSTNAME/default.*
    if [ -f /var/db/dkim/default.private ]; then
        echo "Migrating ${HOSTNAME} keys to /var/db/dkim/$HOSTNAME/"
        mkdir -p /var/db/dkim/$HOSTNAME
        mv /var/db/dkim/default.* /var/db/dkim/$HOSTNAME
        chmod 400 /var/db/dkim/$HOSTNAME/default.private
        chown opendkim:opendkim /var/db/dkim/$HOSTNAME/default.private
    fi

    allDomains="$virtualDomains"
    [[ $allDomains =~ $HOSTNAME ]] || {
        allDomains="$allDomains $HOSTNAME"
    }

    for virtualDomain in $allDomains; do
        # generates new keys only if they are not already present
        if [ ! -f /var/db/dkim/${virtualDomain}/default.private ]; then
            mkdir -p /var/db/dkim/${virtualDomain}
            echo "OpenDKIM: Keys for ${virtualDomain} not found, generating..."
            opendkim-genkey -b 2048 -d ${virtualDomain} -D /var/db/dkim/${virtualDomain} -s default -v
        fi

        chmod 400 /var/db/dkim/${virtualDomain}/default.private
        chown opendkim:opendkim /var/db/dkim/${virtualDomain}/default.private

        echo "Inserting ${virtualDomain} data to /etc/opendkim/{KeyTable, SigningTable, TrustedHosts}"

        if ! grep -q -s "default._domainkey.${virtualDomain}" /etc/opendkim/KeyTable; then
            echo "default._domainkey.${virtualDomain} ${virtualDomain}:default:/var/db/dkim/${virtualDomain}/default.private" >> /etc/opendkim/KeyTable
        fi
        if ! grep -q -s "default._domainkey.${virtualDomain}" /etc/opendkim/SigningTable; then
            echo "${virtualDomain} default._domainkey.${virtualDomain}" >> /etc/opendkim/SigningTable
        fi
        if ! grep -q -s "${virtualDomain}" /etc/opendkim/TrustedHosts; then
            echo "${virtualDomain}" >> /etc/opendkim/TrustedHosts
        fi

        echo "OpenDKIM: this TXT record for ${virtualDomain} should be present:"
        cat /var/db/dkim/${virtualDomain}/default.txt
        
    done

    echo "Configuring DKIM key settings in /etc/opendkim/opendkim.conf"
    sed -e '/KeyFile/ s/^#*/#/' -i /etc/opendkim/opendkim.conf
    sed -e '/Selector/ s/^#*/#/' -i /etc/opendkim/opendkim.conf
    sed -e '/Domain/ s/^#*/#/' -i /etc/opendkim/opendkim.conf

    if ! grep -q -s "KeyTable" /etc/opendkim/opendkim.conf; then
        echo "KeyTable /etc/opendkim/KeyTable" >> /etc/opendkim/opendkim.conf; 
    fi
    if ! grep -q -s "SigningTable" /etc/opendkim/opendkim.conf; then
        echo "SigningTable /etc/opendkim/SigningTable" >> /etc/opendkim/opendkim.conf; 
    fi
    if ! grep -q -s "ExternalIgnoreList" /etc/opendkim/opendkim.conf; then
        echo "ExternalIgnoreList /etc/opendkim/TrustedHosts" >> /etc/opendkim/opendkim.conf; 
    fi
    if ! grep -q -s "InternalHosts" /etc/opendkim/opendkim.conf; then
        echo "InternalHosts /etc/opendkim/TrustedHosts" >> /etc/opendkim/opendkim.conf 
    fi

}

#
# TEST
#
function test_running_env {
    echo ">> Start self-testing..."
    bats test/simple-mail-forwarder.bats

    if [ $? -eq 0 ]
    then
        echo ">> Test PASSED"
    else
        echo ">> Test FAILED!"

        echo ">> !!!!!!!!!!!!!!!!!!!! SYSTEM ERROR !!!!!!!!!!!!!!!!!!!!"
        echo ">> !!!!!!!!!!!!!!!!!!!! SYSTEM ERROR !!!!!!!!!!!!!!!!!!!!"
        echo ">> !!!!!!!!!!!!!!!!!!!! SYSTEM ERROR !!!!!!!!!!!!!!!!!!!!"
        echo ">> !!!!!!!!!!!!!!!!!!!! SYSTEM ERROR !!!!!!!!!!!!!!!!!!!!"
        echo ">> !!!!!!!!!!!!!!!!!!!! SYSTEM ERROR !!!!!!!!!!!!!!!!!!!!"
        echo ">> !!!!!!!!!!!!!!!!!!!! SYSTEM ERROR !!!!!!!!!!!!!!!!!!!!"
        echo ">> !!!!!!!!!!!!!!!!!!!! SYSTEM ERROR !!!!!!!!!!!!!!!!!!!!"

        echo ">> But I'll pretend to run... good luck! :P"
    fi
}



echo ">> Chdir to /app..."
cd /app

[ -e BUILD.env ] && source BUILD.env

# Generated by figlet
cat BANNER

printf "%50s\n" "Source#$GIT_HASH $GIT_DATE * $GIT_BRANCH"
printf "%50s\n\n" "Built on $SMF_BUILD_DATE by $SMF_BUILD_HOST"

if [ "" == "$SMF_DOMAIN" ]
then
    echo ">> ENV SMF_DOMAIN not set."
else
    echo ">> END SMF_DOMAIN found. value:[$SMF_DOMAIN]"
fi

if [ "" == "$SMF_CONFIG" ]
then
    echo ">> END SMF_CONFIG not set."
else
    echo ">> ENV SMF_CONFIG found. value:[$SMF_CONFIG]"
fi

# ARGV
#
#ARGV=$@

if [ "" == "$ARGV" ]
then
    echo ">> ARGV arguments not set."
else
    echo ">> ARGV arguments found. value:[$ARGV]"
fi


if [ "-h" == "$1" ] || [ "--help" == "$1" ] || [ ! "$1" -a ! "$SMF_CONFIG" ]
then
    print_help
    exit 0
elif [ "test" == "$1" ]
then
    opts="test"

    if [ "" != "$2" ]
    then
        if [[ "$2" =~ \.bats$ ]]
        then
            opts="$opts/$2"
        else
            opts="$opts/$2.bats"
        fi
    fi

    # Dummy test data
    SMF_CONFIG="test@test.com:tset@tset.com:test-tset-testo-testi;testo@testo.com:testi@testi.com"
    echo ">> Start mail server by test data: SMF_CONFIG=$SMF_CONFIG"
    start_postfix
    sleep 1

    echo ">> exec bats $opts"
    exec bats $opts

elif [ "sh" == "$1" ] || [ "bash" == "$1" ] || [ "shell" == "$1" ]
then
    tty=$(tty)
    if [ $? -eq 0 ]
    then
        echo ">> You are on TTY $tty."
        echo ">> Enter shell mode."
        exec /bin/bash
        echo ">> Ahh!... Enter shell mode FAILED!"
        exit 1
    else
        echo ">> Ahh!... Enter shell mode FAILED!"
        echo ">> You need TTY to do this."
        echo ">> By add --interactive --tty (or -ti) to Docker run params."
        exit 1
    fi
fi

if [ ! -f /entrypoint.sh ]
then
    >&2 echo ">> you're not inside a valid docker container"
    exit 1;
fi

start_postfix && test_running_env

echo
echo
echo ">> CONGRATULATIONS! System is UP and You are SET!"
echo ">> Powered by SMF - a Simple Mail Forwarder"
echo ">> View in DockerHub: https://hub.docker.com/r/zixia/simple-mail-forwarder"
echo
echo

# Init
echo ">> Init System for Servicing..."
exec /init

# ERROR: exec returned?!
ret=$?
echo ">> Exec ERROR: $ret"
sleep 7
exit $ret
