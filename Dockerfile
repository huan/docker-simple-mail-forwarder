FROM sillelien/base-alpine:0.10
MAINTAINER Zhuohuan LI <zixia@zixia.net>

ENV BATS_VERSION 0.4.0

## Install System

RUN apk update && apk add \
        bash \
        curl \
        drill \
        logrotate \
        openssl \
        postfix \
        cyrus-sasl \
    \
    && curl -s -o "/tmp/v${BATS_VERSION}.tar.gz" -L \
        "https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.tar.gz" \
    && tar -xzf "/tmp/v${BATS_VERSION}.tar.gz" -C /tmp/ \
    && bash "/tmp/bats-${BATS_VERSION}/install.sh" /usr/local \
    \
    && rm -rf /var/cache/apk/* && rm -rf /tmp/*

## Configure Service

COPY install/main.dist.cf /etc/postfix/main.cf
COPY install/master.dist.cf /etc/postfix/master.cf

RUN cat /dev/null > /etc/postfix/aliases && newaliases \
    && echo simple-mail-forwarder.com > /etc/hostname \
    \
    && echo test | saslpasswd2 -p test@test.com \
    && chown postfix /etc/sasldb2 \
    && saslpasswd2 -d test@test.com

## Copy App

WORKDIR /app

COPY install/init-openssl.sh /app/init-openssl.sh
RUN bash -n /app/init-openssl.sh && chmod +x /app/init-openssl.sh

COPY install/postfix.sh /etc/services.d/postfix/run
RUN bash -n /etc/services.d/postfix/run && chmod +x /etc/services.d/postfix/run

COPY entrypoint.sh /entrypoint.sh
RUN bash -n /entrypoint.sh && chmod a+x /entrypoint.sh

COPY BANNER /app/
COPY test /app/test

COPY .git/logs/HEAD /app/GIT_LOG
COPY .git/HEAD /app/GIT_HEAD
COPY install/buildenv.sh /app/

VOLUME ["/etc", "/var/spool/postfix"]

EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


## Log Environment (in Builder)

RUN bash buildenv.sh

