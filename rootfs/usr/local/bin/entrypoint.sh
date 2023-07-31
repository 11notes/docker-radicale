#!/bin/ash
  if [ ! -e "${SSL_ROOT}/cert.pem" ] || [ ! -e "${SSL_ROOT}/key.pem" ]; then
    openssl req -x509 -newkey rsa:${SSL_RSA_BITS} -subj "/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=XX" \
      -keyout "${SSL_ROOT}/key.pem" \
      -out "${SSL_ROOT}/cert.pem" \
      -days 3650 -nodes -sha256 &> /dev/null
  fi

  if [ -z "$1" ]; then
    set -- "/usr/bin/python3" \
      -m radicale \
      --config /radicale/etc/default.conf
  fi

  exec "$@"