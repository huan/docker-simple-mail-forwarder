FROM alpine:3.2
MAINTAINER "LI Zhuohuan" <zixia@zixia.net>

ENV BATS_VERSION 0.4.0

# Install
RUN apk add --update \
    postfix bash make curl ca-certificates \
    \
    && curl -o "/tmp/v${BATS_VERSION}.tar.gz" -L \
        "https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.tar.gz" \
    && tar -xzf "/tmp/v${BATS_VERSION}.tar.gz" -C /tmp/ \
    && bash "/tmp/bats-${BATS_VERSION}/install.sh" /usr/local \
    \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/*

## Configure Postfix

RUN postconf -e smtpd_banner="\$myhostname ESMTP" \
    && postconf -e mail_spool_directory="/var/spool/mail/" \
    && postconf -e mailbox_command="" \
    \
    && postconf -e smtpd_recipient_restrictions="permit_mynetworks reject_unauth_destination" \
    && postconf -e smtpd_helo_restrictions="permit_mynetworks, reject_invalid_hostname, reject_unauth_pipelining, reject_non_fqdn_hostname" \
    \
    && echo simple-mail-forwarder.com > /etc/hostname \
    && touch /var/log/mail.log /var/log/mail.err /var/log/mail.warn \
    && chmod a+rw /var/log/mail.*

## FINISHED

# Add startup script
COPY entrypoint.sh /app/entrypoint.sh
COPY test /app/test
RUN chmod a+x /app/entrypoint.sh

WORKDIR /app

# Postfix Ports
EXPOSE 25

# Docker startup
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["-h"]
