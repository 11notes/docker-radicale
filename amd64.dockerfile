# :: Header
  FROM alpine:latest

# :: SSL Settings
  ENV SSL_RSA_BITS=4096
  ENV SSL_ROOT="/radicale/ssl"
  ENV VERSION=3.1.8

# :: Run
  USER root

  # :: prepare
    RUN set -ex; \
      mkdir -p /radicale/etc; \
      mkdir -p /radicale/var; \
      mkdir -p /home/radicale; \
      mkdir -p /radicale/ssl;

  # :: install
    RUN set -ex; \
      apk add --update --no-cache \
        python3 \
        apache2-utils \
        curl \
        openssl; \
      python3 -m ensurepip; \
      pip3 install --upgrade pip setuptools; \
      /usr/bin/python3 -m pip install --upgrade https://github.com/Kozea/Radicale/archive/refs/tags/v${VERSION}.tar.gz;
      
    RUN set -ex; \
      apk add --update --virtual tmp_bcrypt \
        python3-dev \
        gcc \
        g++ \
        libffi-dev; \
      /usr/bin/python3 -m pip install --upgrade radicale[bcrypt]; \
      apk del tmp_bcrypt;

  # :: copy root filesystem changes
    ADD ./rootfs /

  # :: docker -u 1000:1000 (no root initiative)
    RUN set -ex; \
      addgroup --gid 1000 -S radicale; \
      adduser --uid 1000 -D -S -h /home/radicale -s /sbin/nologin -G radicale radicale; \
      chown -R radicale:radicale \
        /radicale


# :: Volumes
  VOLUME ["/radicale/etc", "/radicale/var"]

# :: Monitor
  RUN chmod +x /usr/local/bin/healthcheck.sh
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  RUN chmod +x /usr/local/bin/entrypoint.sh
  USER radicale
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]