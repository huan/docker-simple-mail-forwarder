FROM alpine:latest
MAINTAINER "LI Zhuohuan" <zixia@zixia.net>

## Install Postfix.

# pre config
RUN echo simple-mail-forwarder.com > /etc/hostname; \
    echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt; \
    echo "postfix postfix/mailname string mail.example.com" >> preseed.txt

# install
RUN apk add --update \
    postfix bash \
    && rm -rf /var/cache/apk/*

## Configure Postfix

RUN postconf -e smtpd_banner="\$myhostname ESMTP"; \
    postconf -e mail_spool_directory="/var/spool/mail/"; \
    postconf -e mailbox_command=""

# postfix settings
RUN postconf -e smtpd_recipient_restrictions="permit_mynetworks reject_unauth_destination"; \
    postconf -e smtpd_helo_restrictions="permit_mynetworks, reject_invalid_hostname, reject_unauth_pipelining, reject_non_fqdn_hostname"

## FINISHED

# Add startup script
ADD entrypoint.sh /app/entrypoint.sh
RUN chmod a+x /app/entrypoint.sh

WORKDIR /app

# Postfix Ports
EXPOSE 25

# Docker startup
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["-h"]
