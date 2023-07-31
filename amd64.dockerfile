# :: Header
  FROM 11notes/alpine:stable

# :: SSL Settings
  ENV APP_VERSION=3.1.8
  ENV APP_ROOT=/radicale
  ENV SSL_RSA_BITS=4096
  ENV SSL_ROOT="${APP_ROOT}/ssl"

# :: Run
  USER root

  # :: prepare
    RUN set -ex; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var; \
      mkdir -p ${APP_ROOT}/ssl;

  # :: install
    RUN set -ex; \
      apk --no-cache add \
        python3 \
        apache2-utils \
        openssl; \
      python3 -m ensurepip; \
      pip3 install --upgrade pip setuptools; \
      /usr/bin/python3 -m pip install --upgrade https://github.com/Kozea/radicale/archive/refs/tags/v${APP_VERSION}.tar.gz;
      
    RUN set -ex; \
      apk --no-cache --virtual vbcrypt add \
        python3-dev \
        gcc \
        g++ \
        libffi-dev; \
      /usr/bin/python3 -m pip install --upgrade radicale[bcrypt]; \
      apk del vbcrypt;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]