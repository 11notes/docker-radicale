# :: Header
    FROM alpine:3.14.1

    # :: SSL Settings
        ENV SSL_RSA_BITS=4096
        ENV SSL_ROOT="/radicale/ssl"

# :: Run
    USER root

    # :: prepare
        RUN mkdir -p /radicale/etc \
            && mkdir -p /radicale/var \
            && mkdir -p /home/radicale \
            mkdir -p /radicale/ssl


    # :: install
        RUN apk add --update --no-cache \
                python3 apache2-utils curl openssl \
            && python3 -m ensurepip \
            && pip3 install --upgrade pip setuptools

        RUN /usr/bin/python3 -m pip install --upgrade radicale

        RUN apk add --update --virtual tmp_bcrypt python3-dev gcc g++ libffi-dev openssl \
            && /usr/bin/python3 -m pip install --upgrade radicale[bcrypt] \
            && apk del tmp_bcrypt

    # :: CI/CD
        RUN echo "CI/CD{{$(radicale --version 2>&1)}}"

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN addgroup --gid 1000 -S radicale \
            && adduser --uid 1000 -D -S -h /home/radicale -s /sbin/nologin -G radicale radicale
        RUN chown -R radicale:radicale /radicale


# :: Volumes
    VOLUME ["/radicale/etc", "/radicale/var"]

# :: Monitor
    RUN chmod +x /usr/local/bin/healthcheck.sh
    HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
    RUN chmod +x /usr/local/bin/entrypoint.sh
    USER radicale
    ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]