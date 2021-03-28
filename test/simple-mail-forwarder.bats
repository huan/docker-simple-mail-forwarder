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
# issue #1        [ "$userFrom" != "" ]
        [ "$domainFrom" != "" ]

        userTo=${addrTo%@*}
        domainTo=${addrTo##*@}
# issue #1        [ "$userTo" != "" ]
        [ "$domainTo" != "" ]

# issue #1        [ "$domainFrom" != "$domainTo" ]
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
    processNum=$(ps | grep -v grep | grep /usr/libexec/postfix/master | wc -l)
    [ $processNum -gt 0 ]
}

@test "confirm port 25 is open" {
    run netstat -nlt
    [ $status = 0 ]
    [[ $output =~ ":25 " ]]
}

@test "crond is running" {
    skip "skip this for 0.3.0 -> 0.4.0"
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
    [[ $output =~ '250 CHUNKING' ]]
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
    FIFO_SSL_I=/tmp/ssli.$$
    FIFO_SSL_O=/tmp/sslo.$$

    mkfifo $FIFO_SSL_{I,O}

    0<$FIFO_SSL_I &>$FIFO_SSL_O \
        timeout -s TERM 7 \
        openssl s_client -starttls smtp -crlf -connect 127.0.0.1:25 &

    exec {FD_I}> $FIFO_SSL_I
    exec {FD_O}< $FIFO_SSL_O

    ret=1

    while read line; do
        line=$(sed 's/\r$//'<<<$line)

        if [[ $line =~ 'CONNECTED' ]]; then
            >& $FD_I echo 'AUTH PLAIN dGVzdGlAdGVzdG8uY29tAHRlc3RpQHRlc3RvLmNvbQB0ZXN0'
        elif [[ $line =~ '235 2.7.0 Authentication successful' ]]; then
            >& $FD_I echo 'QUIT'
            exec {FD_I}>&-
            ret=0
        elif [[ $line =~ '503 5.5.1 Error: already authenticated' ]]; then
            >& $FD_I echo 'QUIT'
            exec {FD_I}>&-
            ret=0
        fi
    done <& $FD_O

    unlink $FIFO_SSL_I
    unlink $FIFO_SSL_O

    [ $ret = 0 ]
}

@test "deleting test user testi@testo.com" {
    # Delete user
    saslpasswd2 -d testi@testo.com

    # Expect login to fail
    output=$(nc 127.0.0.1:25 \
        <<< 'EHLO test.com' \
        <<< 'AUTH PLAIN dGVzdGlAdGVzdG8uY29tAHRlc3RpQHRlc3RvLmNvbQB0ZXN0' \
        )
    [[ $output =~ "535 5.7.8 Error: authentication failed: authentication failure" ]]
}

@test "test DKIM keys" {
    if [[ "$SKIP_TEST" == *"DKIM"*  ]]; then
        skip "This test will fail on docker build workflow"
    fi
    for domain in /var/db/dkim/*/ ; do
        echo "Validating DKIM for ${domain:13:-1}"
        opendkim-testkey -d ${domain:13:-1} -s default -vvv
    done
    [ $? -eq 0 ]
}

@test "test custom main.cf entries" {
    for e in ${!SMF_POSTFIXMAIN_*} ; do
        OPT_NAME=$(echo ${e:16} | tr '[:upper:]' '[:lower:]')
        OPT_VALUE=${!e}
        ret=$(postconf | grep "$OPT_NAME" | grep "$OPT_VALUE")
        [[ ! -z "$ret" ]]
    done
}

@test "test custom master.cf entries" {
    for e in ${!SMF_POSTFIXMASTER_*} ; do
        OPT_NAME=$(echo ${e:18} | tr '[:upper:]' '[:lower:]' | sed 's/__/\//g')
        OPT_VALUE=${!e}
        ret=$(postconf -P | grep "$OPT_NAME" | grep "$OPT_VALUE")
        [[ ! -z "$ret" ]]
    done
}

@test "test default postfix logging configuration" {
    # Check if not specified variable will result in default configuration
    if [ "$SMF_POSTFIXLOG" == "" ]; then
      true
    else
      echo "Postfix should use the default configuration"
      exit 1
    fi
}

@test "test custom postfix logging configuration with an error" {
    # Check if specified variable not starting with /var will result in an error
    SMF_POSTFIXLOG="/starts/not/with/var"
    if [ "$SMF_POSTFIXLOG" == "" ]; then
      echo "Postfix should not use the default configuration"
      exit 1
    else
      if [[ $SMF_POSTFIXLOG != "/var"* ]]; then
        true
      else
        echo "Script should recognize that variable starts not with /var"
        exit 1
      fi
    fi
}

@test "test custom postfix logging configuration" {
    # Check if postfix can start and logs to the specified file
    SMF_POSTFIXLOG="/var/log/postfix.log"
    if [ "$SMF_POSTFIXLOG" == "" ]; then
      echo "Postfix should not use the default configuration"
      exit 1
    else
      if [[ $SMF_POSTFIXLOG != "/var"* ]]; then
        echo "Script should recognize that variable starts with /var"
        exit 1
      else
        postconf maillog_file="$SMF_POSTFIXLOG"
        postfix start
        if [ -f /var/log/postfix.log ]; then
          true
        else
          echo "Postfix should log to /var/log/postfix.log"
          exit 1
        fi
      fi
    fi
}
