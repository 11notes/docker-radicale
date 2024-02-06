#!/bin/ash
  if [ ! -f "${APP_ROOT}/ssl/default.key" ]; then
    elevenLogJSON info "creating default ssl certificates"
    openssl req -x509 -newkey rsa:4096 -subj "/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=${APP_NAME}" \
      -keyout "${APP_ROOT}/ssl/default.key" \
      -out "${APP_ROOT}/ssl/default.crt" \
      -days 3650 -nodes -sha256 &> /dev/null
  fi

  if [ -z "${1}" ]; then
    elevenLogJSON info "starting ${APP_NAME}"
    set -- "/usr/bin/python3" \
      -m radicale \
      --config /radicale/etc/default.conf
  fi

  exec "$@"