FROM alpine:3.2
MAINTAINER "LI Zhuohuan" <zixia@zixia.net>

ENV BATS_VERSION 0.4.0

# Install
RUN apk add --update \
        postfix bash curl \
    \
    && mkdir -p /lib/modules \
    && sed -i 's/^\(\s*\)hostname/#\1hostname/g' /etc/init.d/hostname \
    && rm /sbin/hwclock && echo "#/bin/sh\nexit 0" > /sbin/hwclock && chmod +x /sbin/hwclock \
    \
    && rc-update add postfix \
    && rc-status \
    && touch /run/openrc/softlevel \
    \
    && /etc/init.d/postfix start \
    && /etc/init.d/postfix stop \
    && /etc/init.d/syslog start \
    && /etc/init.d/syslog stop \
    \
    && curl -o "/tmp/v${BATS_VERSION}.tar.gz" -L \
        "https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.tar.gz" \
    && tar -xzf "/tmp/v${BATS_VERSION}.tar.gz" -C /tmp/ \
    && bash "/tmp/bats-${BATS_VERSION}/install.sh" /usr/local \
    \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

## Configure Postfix

RUN postconf -e smtpd_banner="\$myhostname ESMTP" \
    && postconf -e mail_spool_directory="/var/spool/mail/" \
    && postconf -e mailbox_command="" \
    && postconf -e smtputf8_enable="no" \
    \
    && postconf -e smtpd_recipient_restrictions="permit_mynetworks reject_unauth_destination" \
    && postconf -e smtpd_helo_restrictions="permit_mynetworks, reject_invalid_hostname, reject_unauth_pipelining, reject_non_fqdn_hostname" \
    \
    && cat /dev/null > /etc/postfix/aliases && newaliases \
    && echo simple-mail-forwarder.com > /etc/hostname

## FINISHED

# COPY Configuration Files
COPY entrypoint.sh  /app/entrypoint.sh
COPY test           /app/test

RUN chmod a+x /app/entrypoint.sh

WORKDIR /app

# SMTP Ports
EXPOSE 25

# Docker Entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
