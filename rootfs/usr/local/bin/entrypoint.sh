#!/bin/ash
  openssl req -x509 -newkey rsa:4096 -subj "/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=XX" \
    -keyout "${APP_ROOT}/ssl/key.pem" \
    -out "${APP_ROOT}/ssl/cert.pem" \
    -days 3650 -nodes -sha256 &> /dev/null

  if [ -z "$1" ]; then
    set -- "/usr/bin/python3" \
      -m radicale \
      --config /radicale/etc/default.conf
  fi

  exec "$@"