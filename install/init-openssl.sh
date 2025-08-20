#!/bin/bash

[ -d /etc/postfix/cert ] || {
    mkdir -p /etc/postfix/cert
}

cd /etc/postfix/cert

# If either certificate exists, don't generate any certificates
if [ -f "smtp.cert" ] || [ -f "smtp.ec.cert" ]; then
  # If RSA cert does not exist, comment out smtpd_tls_cert_file & smtpd_tls_key_file
  if [ ! -f "smtp.cert" ]; then
    sed -ine '/\(smtpd_tls_cert_file\|smtpd_tls_key_file\)/s/^/#/' /etc/postfix/main.cf
  fi

  # If EC cert does not exist, comment out smtpd_tls_eccert_file & smtpd_tls_eckey_file
  if [ ! -f "smtp.ec.cert" ]; then
    sed -ine '/\(smtpd_tls_eccert_file\|smtpd_tls_eckey_file\)/s/^/#/' /etc/postfix/main.cf
  fi

else
  # skip generation of certificate if one exists (by mounting a volume)
  if [ ! -f "smtp.cert" ]; then
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
  fi

  if [ ! -f "smtp.ec.cert" ]; then
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
  fi
fi
chown -R root.postfix /etc/postfix/cert/
chmod -R 750 /etc/postfix/cert/
