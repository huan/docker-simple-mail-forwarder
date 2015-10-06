FROM alpine:3.2
MAINTAINER Zhuohuan LI <zixia@zixia.net>

ENV BATS_VERSION 0.4.0

## System Install

RUN apk add --update \
        bash \
        curl \
        postfix \
        cyrus-sasl \
    \
    && mkdir -p /lib/modules \
    && sed -i 's/^\(\s*\)hostname/#\1hostname/g' /etc/init.d/hostname \
    && rm /sbin/hwclock && echo "#/bin/sh\nexit 0" > /sbin/hwclock && chmod +x /sbin/hwclock \
    \
    && curl -s -o "/tmp/v${BATS_VERSION}.tar.gz" -L \
        "https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.tar.gz" \
    && tar -xzf "/tmp/v${BATS_VERSION}.tar.gz" -C /tmp/ \
    && bash "/tmp/bats-${BATS_VERSION}/install.sh" /usr/local \
    \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*


## Service Configure

COPY install/main.dist.cf /etc/postfix/main.cf
COPY install/master.dist.cf /etc/postfix/master.cf

RUN mkdir /run/openrc && touch /run/openrc/softlevel \
    && cat /dev/null > /etc/postfix/aliases && newaliases \
    && echo simple-mail-forwarder.com > /etc/hostname \
    && rc-update add postfix \
    && rc-status 

RUN echo test | saslpasswd2 -p test@test.com \
    && chown postfix /etc/sasldb2 \
    && saslpasswd2 -d test@test.com

COPY install/init.sh /app/init.sh
RUN bash -n /app/init.sh && chmod +x /app/init.sh


## App Install

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
RUN bash -n /entrypoint.sh && chmod a+x /entrypoint.sh

COPY test /app/test

VOLUME ["/etc", "/var/spool/postfix"]

EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


## Log Build Environment

RUN echo "SMF_BUILD_DATE='`date`'" > /app/BUILD.env \
    && echo "SMF_BUILD_HOST='`hostname`'" >> /app/BUILD.env \
    \
    && echo "GIT_BRANCH='$GIT_BRANCH'" >> /app/BUILD.env \
    && echo "GIT_TAG='$GIT_TAG'" >> /app/BUILD.env \
    && echo "GIT_SHA1='$GIT_SHA1'" >> /app/BUILD.env \
    && echo "IMAGE_NAME='$IMAGE_NAME'" >> /app/BUILD.env
