FROM alpine:3.2
MAINTAINER Zhuohuan LI <zixia@zixia.net>

ENV BATS_VERSION 0.4.0

## System Install

RUN apk add --update \
        bash \
        curl \
        postfix \
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


## System Configure

RUN mkdir /run/openrc && touch /run/openrc/softlevel \
    && postconf -e smtpd_banner="\$myhostname ESMTP" \
    && postconf -e mail_spool_directory="/var/spool/mail/" \
    && postconf -e mailbox_command="" \
    && postconf -e smtputf8_enable="no" \
    \
    && postconf -e smtpd_recipient_restrictions="permit_mynetworks reject_unauth_destination" \
    && postconf -e smtpd_helo_restrictions="permit_mynetworks, reject_invalid_hostname, reject_unauth_pipelining, reject_non_fqdn_hostname" \
    \
    && cat /dev/null > /etc/postfix/aliases && newaliases \
    && echo simple-mail-forwarder.com > /etc/hostname \
    \
    && rc-update add postfix \
    && rc-status \
    \
    && service postfix start \
    && service postfix stop
 

## App Install

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
RUN bash -n /entrypoint.sh

COPY test /app/test

RUN chmod a+x /entrypoint.sh

VOLUME /var/spool/postfix

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
