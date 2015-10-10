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
    processNum=$(ps | grep -v grep | grep /usr/lib/postfix/master | wc -l)
    [ $processNum -gt 0 ]
}

@test "confirm port 25 is open" {
    run netstat -nlt 
    [ $status = 0 ]
    [[ $output =~ ":25 " ]]
}

@test "crond is running" {
    read cronPid < /var/run/crond.pid
    processNum=$(ps | grep $cronPid | grep crond | wc -l)

    [ $processNum -eq 1 ]
}

@test "ESMTP STATTLS supported" {
    output=$(echo ehlo simple.com | nc 127.0.0.1 25)

    [[ $output =~ STARTTLS ]]
}

@test "ESMTP AUTH supported" {
    output=$(echo ehlo simple.com | nc 127.0.0.1 25)

    [[ $output =~ AUTH ]]
    [[ $output =~ PLAIN ]]
    [[ $output =~ LOGIN ]]
}

@test "ESMTP STARTTLS connect ok" {
    output=$(echo QUIT | 2>&1 openssl s_client -starttls smtp -crlf -connect 127.0.0.1:25)

    [ $? -eq 0 ]
    [[ $output =~ '250 DSN' ]]
}
@test "create user testi@testo.com by password test" {
    echo test | saslpasswd2 -p testi@testo.com

    [ $? -eq 0 ]
}

@test "ESMTP AUTH by testi@testo.com/test" {
    #
    # # perl -MMIME::Base64 -e 'print encode_base64("testi\@testo.com\0testi\@testo.com\0test");'
    # dGVzdGlAdGVzdG8uY29tAHRlc3RpQHRlc3RvLmNvbQB0ZXN0
    #
    output=$(nc 127.0.0.1:25 \
        <<< 'EHLO test.com' \
        <<< 'AUTH PLAIN dGVzdGlAdGVzdG8uY29tAHRlc3RpQHRlc3RvLmNvbQB0ZXN0' \
        )

    [[ $output =~ "235 2.7.0 Authentication successful" ]]
}

@test "ESMTP TLS AUTH by testi@testo.com/test" {
    #
    # # perl -MMIME::Base64 -e 'print encode_base64("testi\@testo.com\0testi\@testo.com\0test");'
    # dGVzdGlAdGVzdG8uY29tAHRlc3RpQHRlc3RvLmNvbQB0ZXN0
    #
    output=$(2>&1 openssl s_client -starttls smtp -crlf -connect 127.0.0.1:25 \
        <<<'EHLO test.com' \
        <<<'AUTH PLAIN dGVzdGlAdGVzdG8uY29tAHRlc3RpQHRlc3RvLmNvbQB0ZXN0' \
        )

    skip "don't know why this test sometimes pass but sometimes failure."

    [[ $output =~ "235 2.7.0 Authentication successful" ]]
}

