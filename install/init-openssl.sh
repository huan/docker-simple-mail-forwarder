#!/bin/bash

[ -d /etc/postfix/cert ] || {
    mkdir -p /etc/postfix/cert
}

cd /etc/postfix/cert
# skip generation of certificate if one exists (by mounting a volume)
if [ ! -f "smtp.cert" ] || [ ! -f "smtp.ec.cert" ]; then
    openssl req \
        -new \
        -outform PEM \
        -nodes \
        -keyform PEM \
        -days 3650 \
        -x509 \
        -subj "/C=US/ST=Matrix/L=L/O=O/CN=${SMF_DOMAIN:-simple-mail-forwarder.com}" \
        \
        -newkey rsa:2048 \
        -keyout smtp.key \
        -out smtp.cert

    openssl req \
        -new \
        -outform PEM \
        -nodes \
        -keyform PEM \
        -days 3650 \
        -x509 \
        -subj "/C=US/ST=Matrix/L=L/O=O/CN=${SMF_DOMAIN:-simple-mail-forwarder.com}" \
        \
        -newkey ec:<(openssl ecparam -name secp384r1) \
        -keyout smtp.ec.key \
        -out smtp.ec.cert

    chown -R root.postfix /etc/postfix/cert/
    chmod -R 750 /etc/postfix/cert/
fi
