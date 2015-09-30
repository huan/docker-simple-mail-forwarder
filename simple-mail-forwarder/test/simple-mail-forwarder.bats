#!/usr/bin/env bats

@test "SMF_CONFIG exist" {
    [ -f /app/SMF_CONFIG.env ]
    . /app/SMF_CONFIG.env
    [ "$SMF_CONFIG" != "" ]
    [[ "$SMF_CONFIG" =~ [.:]+ ]]
}

@test "SMF_DOMAIN exist" {
    [ -f /app/SMF_DOMAIN.env ]
    . /app/SMF_DOMAIN.env
    [ "$SMF_DOMAIN" != "" ]
    [[ "$SMF_DOMAIN" =~ [a-zA-Z0-9_-]+\.[a-zA-Z]{2,}$ ]]
}

@test "virtual maping source is set" {
    [ -f /etc/postfix/virtual ]
}

@test "virtual maping data is set" {
    while read -r addrFrom addrTo; do
    	[ ! "$addrFrom" -o ! "$addrTo" ] && continue

        userFrom=${addrFrom%@*}
        domainFrom=${addrFrom##*@}
        [ "$userFrom" != "" ]
        [ "$domainFrom" != "" ]

        userTo=${addrTo%@*}
        domainTo=${addrTo##*@}
        [ "$userTo" != "" ]
        [ "$domainTo" != "" ]

        [ "$domainFrom" != "$domainTo" ]
    done < /etc/postfix/virtual
}

@test "virtual maping db is set" {
    [ -f /etc/postfix/virtual.db ]
}

@test "system hostname FQDN resolvable" {
    hostname=`cat /etc/hostname`
    [[ $hostname =~ [a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]{2,}$ ]]

    run nslookup $hostname
    [ $status = 0 ]
}

@test "postfix myhostname FQDN & resolvable" {
    run postconf myhostname
    [ $status = 0 ]
    [[ "${lines[0]}" =~ ^myhostname ]]


    myhostname=${lines[0]##* = }
    run nslookup $myhostname
    [ $status = 0 ]
}

@test "check other hostname setting" {
    [ "`cat /etc/mailname`" = "`cat /etc/hostname`" ]
}

@test "confirm postfix is running" {
    processNum=$(ps | grep -v grep | grep postfix | wc -l)
    [ $processNum -gt 0 ]
}

@test "confirm port 25 is open" {
    run netstat -nlt 
    [ $status = 0 ]
    [[ $output =~ ":25 " ]]
}
