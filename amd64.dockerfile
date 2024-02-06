# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM 11notes/apk-build:stable as build
  ENV APK_NAME="radicale"
  ENV APK_VERSION="3.1.8"

  USER root

  RUN set -ex; \
    cd ~; \
    newapkbuild ${APK_NAME};

  COPY ./build /apk/${APK_NAME}

  RUN set -ex; \
    cd ~/${APK_NAME}; \
    sed -i "s/\$APK_VERSION/${APK_VERSION}/g" ./APKBUILD; \
    abuild checksum; \
    abuild -r;

# :: Header
  FROM 11notes/alpine:stable
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  COPY --from=build /apk/packages/apk /tmp
  ENV APK_NAME="radicale"
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