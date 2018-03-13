#!/bin/bash

CERTIFICATE_DIR=$(dirname $CERTIFICATE_PUBLIC)
CERTIFICATE_PUBLIC_FILE=$(basename $CERTIFICATE_PUBLIC)
CERTIFICATE_PRIVATE_FILE=$(basename $CERTIFICATE_PRIVATE)

[ -d $CERTIFICATE_DIR ] || {
    mkdir -p $CERTIFICATE_DIR
}

cd $CERTIFICATE_DIR
# skip generation of certificate if one exists (by mounting a volume)
if [ ! -f ${CERTIFICATE_PUBLIC} ]; then
    #openssl dhparam -2 -out dh_512.pem 512
    #openssl dhparam -2 -out dh_1024.pem 1024
    openssl req -new -outform PEM -out $CERTIFICATE_PUBLIC_FILE -newkey rsa:2048 \
            -nodes -keyout $CERTIFICATE_PRIVATE_FILE -keyform PEM -days 3650 -x509 \
            -subj "/C=US/ST=Matrix/L=L/O=O/CN=${SMF_DOMAIN:-simple-mail-forwarder.com}"

    chown -R root.postfix /etc/postfix/cert/
    chmod -R 750 /etc/postfix/cert/
fi
