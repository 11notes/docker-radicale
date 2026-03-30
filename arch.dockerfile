# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      APP_GO_VERSION=0 \
      APP_PYTHON_VERSION=0

# :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/distroless:localhealth AS distroless-localhealth


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: ENTRYPOINT
  FROM 11notes/go:${APP_GO_VERSION} AS entrypoint
  COPY ./build /

  RUN set -ex; \
    cd /go/entrypoint; \
    eleven go build /entrypoint main.go; \
    eleven distroless /entrypoint;


# :: RADICALE
  FROM 11notes/python:${APP_PYTHON_VERSION} AS build
  ARG APP_VERSION
  USER root

  RUN set -ex; \
    pip install \
      uv;

  RUN set -ex; \
    uv pip install \
      --only-binary=:all: \
      radicale=="${APP_VERSION}" \
      radicale[bcrypt]=="${APP_VERSION}" \
      radicale[argon2]=="${APP_VERSION}" \
      radicale[ldap]=="${APP_VERSION}";

  RUN set -ex; \
    pip uninstall -y \
      uv;

# :: FILE-SYSTEM
  FROM alpine AS file-system
  ARG APP_ROOT
  
  RUN set -ex; \
    mkdir -p /distroless${APP_ROOT}/etc; \
    mkdir -p /distroless${APP_ROOT}/var;

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
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs/ /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:5232/", "-I"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/entrypoint"]