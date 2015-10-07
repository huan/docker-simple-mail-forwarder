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

Enviroment Variables:
    SMF_DOMAIN - mail server hostname. use tutum/docker hostname if omitted.
    SMF_CONFIG - mail forward addresses maping list.

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
    bash /app/init.sh

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

        echo ">> Setting password [ $password ] for user $emailFrom ..."
        echo $password | saslpasswd2 $emailFrom

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

    echo "SMF_DOMAIN='$HOSTNAME'" > SMF_DOMAIN.env

    echo ">> Set hostname to $HOSTNAME"


    # add domain
    postconf -e myhostname="$HOSTNAME"
    postconf -e mydestination="localhost"
    echo "$HOSTNAME" > /etc/mailname
    echo "$HOSTNAME" > /etc/hostname

    # XXX permition denied in docker? - zixia 20150930
    #hostname "$HOSTNAME"


    # starting services
    echo ">> Starting the services"
    service syslog start
    service cron start
    service postfix start
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
        echo ">> FIX need."
        exit 1
    fi
}


cat <<_BANNER
 ____  _                 _         __  __       _ _
/ ___|(_)_ __ ___  _ __ | | ___   |  \\/  | __ _(_) |
\\___ \\| | '_ \` _ \\| '_ \\| |/  _ \\ | |\\/| |/ _\` | | |
 ___) | | | | | | | |_) | |  __/  | |  | | (_| | | |
|____/|_|_| |_| |_| .__/|_|\\___|  |_|  |_|\\__,_|_|_|
                  |_|
 _____                                _
|  ___|__  _ ____      ____ _ _ __ __| | ___ _ __
| |_ / _ \\| '__\\ \\ /\\ / / _\` | '__/ _\` |/ _ \\ '__|
|  _| (_) | |   \ V  V / (_| | | | (_| |  __/ |
|_|  \___/|_|    \_/\_/ \__,_|_|  \__,_|\___|_|


_BANNER

echo ">> Chdir to /app..."
cd /app

. BUILD.env

echo ">> SMF Build on $SMF_BUILD_DATE by $SMF_BUILD_HOST"
echo ">> SMF $GIT_BRANCH/$GIT_TAG/$GIT_SHA1/$IMAGE_NAME"


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

# print logs
echo ">> Printing the logs"
tail -F /var/log/*
