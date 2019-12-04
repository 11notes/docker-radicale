#!/bin/sh
if [ ! -e "${SSL_ROOT}/cert.pem" ] || [ ! -e "${SSL_ROOT}/key.pem" ]
then
    echo "creating SSL certificate and key for encryption ..."
    openssl req -x509 -newkey rsa:${SSL_RSA_BITS} -subj "/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=XX" \
        -keyout "${SSL_ROOT}/key.pem" \
        -out "${SSL_ROOT}/cert.pem" \
        -days 3650 -nodes -sha256 &> /dev/null
    echo "${SSL_RSA_BITS}bit RSA key created!"
fi

echo "starting radicale"
exec /usr/bin/python3 -m radicale --config /radicale/etc/default.conf