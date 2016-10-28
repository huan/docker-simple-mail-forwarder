#!/bin/bash

[ -d /etc/postfix/cert ] || {
    mkdir -p /etc/postfix/cert
}

cd /etc/postfix/cert
# skip generation of certificate if one exists (by mounting a volume)
if [ ! -f "smtp.cert" ]; then
    #openssl dhparam -2 -out dh_512.pem 512
    #openssl dhparam -2 -out dh_1024.pem 1024
    openssl req -new -outform PEM -out smtp.cert -newkey rsa:2048 \
            -nodes -keyout smtp.key -keyform PEM -days 3650 -x509 \
            -subj "/C=US/ST=Matrix/L=L/O=O/CN=${SMF_DOMAIN:-simple-mail-forwarder.com}"

    chown -R root.postfix /etc/postfix/cert/
    chmod -R 750 /etc/postfix/cert/
fi
