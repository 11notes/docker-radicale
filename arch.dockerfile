# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000
  ARG PYTHON_VERSION=3.13

# :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/distroless:localhealth AS distroless-localhealth


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: ENTRYPOINT
  FROM 11notes/go:1.25 AS entrypoint
  COPY ./build /

  RUN set -ex; \
    cd /go/entrypoint; \
    eleven go build /entrypoint main.go; \
    eleven distroless /entrypoint;

# :: WHEELS
  FROM 11notes/python:wheel-${PYTHON_VERSION} AS wheels
  ARG APP_VERSION
  USER root

  RUN set -ex; \
    mkdir -p /pip/wheels;

  RUN set -ex; \
    pip wheel \
      --wheel-dir /pip/wheels \
      -f https://11notes.github.io/python-wheels/ \
      radicale=="${APP_VERSION}" \
      radicale[bcrypt]=="${APP_VERSION}" \
      radicale[argon2]=="${APP_VERSION}" \
      radicale[ldap]=="${APP_VERSION}";

# :: RADICALE
  FROM 11notes/python:${PYTHON_VERSION} AS build
  COPY --from=wheels /pip/wheels /pip/wheels
  ARG APP_VERSION \
      APP_UID \
      APP_GID
  USER root

  RUN set -ex; \
    pip install \
      --no-index \
      -f /pip/wheels \
      radicale=="${APP_VERSION}" \
      radicale[bcrypt]=="${APP_VERSION}" \
      radicale[argon2]=="${APP_VERSION}" \
      radicale[ldap]=="${APP_VERSION}"; \
    rm -rf /pip;

# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=distroless-localhealth / /
    COPY --from=entrypoint /distroless/ /
    COPY --from=build / /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs/ /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:5232/", "-I"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/entrypoint"]