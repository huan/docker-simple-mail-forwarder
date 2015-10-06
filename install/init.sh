#!/bin/bash

[ -d /etc/postfix/cert ] || {
    mkdir -p /etc/postfix/cert
}

cd /etc/postfix/cert

openssl dhparam -2 -out dh_512.pem 512
openssl dhparam -2 -out dh_1024.pem 1024
openssl req -new -outform PEM -out smtp.cert -newkey rsa:1024 \
            -nodes -keyout smtp.key -keyform PEM -days 365 -x509 \
            -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"

chown -R postfix:root /etc/postfix/cert/
chmod -R 600 /etc/postfix/cert/
