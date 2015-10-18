FROM alpine:3.2
MAINTAINER Zhuohuan LI <zixia@zixia.net>

ENV BATS_VERSION 0.4.0

## Install System

RUN apk add --update \
        bash \
        curl \
        drill \
        logrotate \
        postfix \
        cyrus-sasl \
    \
    && curl -s -o "/tmp/v${BATS_VERSION}.tar.gz" -L \
        "https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.tar.gz" \
    && tar -xzf "/tmp/v${BATS_VERSION}.tar.gz" -C /tmp/ \
    && bash "/tmp/bats-${BATS_VERSION}/install.sh" /usr/local \
    \
    && touch /var/log/messages \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

## Configure Service

COPY install/main.dist.cf /etc/postfix/main.cf
COPY install/master.dist.cf /etc/postfix/master.cf

RUN mkdir /run/openrc && echo default > /run/openrc/softlevel \
    && cat /dev/null > /etc/postfix/aliases && newaliases \
    && echo simple-mail-forwarder.com > /etc/hostname \
    \
    && sed -i '/rc_controller_cgroups/ c\rc_controller_cgroups="NO"' /etc/rc.conf \
    && sed -i '/rc_sys/c rc_sys="lxc"' /etc/rc.conf \
    \
    && sed -i 's/cgroup_add_service/cgroup_add_service_DISABLED/g' /lib/rc/sh/openrc-run.sh\
    \
    && rc-update add postfix default \
    && rc-status

RUN echo test | saslpasswd2 -p test@test.com \
    && chown postfix /etc/sasldb2 \
    && saslpasswd2 -d test@test.com

COPY install/init.sh /app/init.sh
RUN bash -n /app/init.sh && chmod +x /app/init.sh


## Copy App

WORKDIR /app

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

