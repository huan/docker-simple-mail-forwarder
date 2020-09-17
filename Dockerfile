FROM alpine:3.12
LABEL maintainer="Huan LI <zixia@zixia.net>"

ENV BATS_VERSION 1.2.1
ENV S6_VERSION 2.1.0.0

## Install System

RUN apk add --update --no-cache \
        bash \
        coreutils \
        curl \
        cyrus-sasl \
        cyrus-sasl-plain \
        cyrus-sasl-login \
        ca-certificates \
        drill \
        logrotate \
        opendkim \
        opendkim-utils \
        openssl \
        postsrsd \
        postfix \
        syslog-ng \
        tzdata \
    \
    && curl -s -o "/tmp/v${BATS_VERSION}.tar.gz" -L \
        "https://github.com/bats-core/bats-core/archive/v${BATS_VERSION}.tar.gz" \
    && tar -xzf "/tmp/v${BATS_VERSION}.tar.gz" -C /tmp/ \
    && bash "/tmp/bats-core-${BATS_VERSION}/install.sh" /usr/local \
    \
    && rm -rf /tmp/*

## Install s6 process manager
RUN curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-nobin.tar.gz \
  | tar xzf - -C /

## Configure Service

COPY install/main.dist.cf /etc/postfix/main.cf
COPY install/master.dist.cf /etc/postfix/master.cf
COPY install/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

RUN cat /dev/null > /etc/postfix/aliases && newaliases \
    && echo simple-mail-forwarder.com > /etc/hostname \
    \
    && echo test | saslpasswd2 -p test@test.com \
    && chown postfix /etc/sasl2/sasldb2 \
    && saslpasswd2 -d test@test.com

## Copy App

WORKDIR /app

COPY install/init-openssl.sh /app/init-openssl.sh
RUN bash -n /app/init-openssl.sh && chmod +x /app/init-openssl.sh

COPY install/postfix.sh /etc/services.d/postfix/run
RUN bash -n /etc/services.d/postfix/run && chmod +x /etc/services.d/postfix/run

COPY install/syslog-ng.sh /etc/services.d/syslog-ng/run
RUN bash -n /etc/services.d/syslog-ng/run && chmod +x /etc/services.d/syslog-ng/run

COPY entrypoint.sh /entrypoint.sh
RUN bash -n /entrypoint.sh && chmod a+x /entrypoint.sh

COPY BANNER /app/
COPY test /app/test

COPY .git/logs/HEAD /app/GIT_LOG
COPY .git/HEAD /app/GIT_HEAD
COPY install/buildenv.sh /app/

VOLUME ["/var/spool/postfix"]

EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


## Log Environment (in Builder)

RUN bash buildenv.sh

