# :: Arch
  FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu

# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Header
  FROM 11notes/alpine:arm64v8-stable
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  ENV APP_NAME="radicale"
  ENV APP_VERSION="3.1.8-r2"
  ENV APP_ROOT=/radicale

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      ls -lah /tmp; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var; \
      mkdir -p ${APP_ROOT}/ssl;

  # :: install application
    RUN set -ex; \
      apk add --no-cache --allow-untrusted --repository /tmp \
        radicale; \
      apk add --no-cache \
        radicale=${APP_VERSION} \
        openssl \
        py3-pip \
        py3-ldap3; \
      rm -rf /tmp/*; \
      apk --no-cache \
        upgrade;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: install plugins
    RUN set -ex; \
      cd /plugins/radicale_auth_ldap; \
      python3 -m pip install . --break-system-packages;

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