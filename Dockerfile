# :: Header
FROM alpine:3.10

# :: Run
RUN mkdir -p /radicale/etc \
    && mkdir -p /radicale/var \
    && mkdir -p /home/radicale \
    mkdir -p /radicale/ssl

RUN apk add --update  --no-cache python3 apache2-utils curl \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip setuptools

RUN /usr/bin/python3 -m pip install --upgrade radicale

RUN apk add --update --no-cache --virtual .dep_bcrypt python3-dev gcc g++ libffi-dev openssl \
    && /usr/bin/python3 -m pip install --upgrade radicale[bcrypt] \
    && openssl req -x509 -newkey rsa:4096 -keyout /radicale/ssl/server.key -out /radicale/ssl/server.crt -nodes -days 9999 \
    && apk del .dep_bcryp

# :: Version
RUN echo "CI/CD{{$(radicale --version 2>&1)}}"

# :: docker -u 1000:1000 (no root initiative)
RUN addgroup --gid 1000 -S radicale \
	&& adduser --uid 1000 -D -S -h /home/radicale -s /sbin/nologin -G radicale radicale
RUN chown -R radicale:radicale /radicale

ADD ./source/radicale.conf /radicale/etc/default.conf
ADD ./source/rights.conf /radicale/etc/rights
ADD ./source/users.bcrypt /radicale/etc/users

ADD ./source/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# :: Volumes
VOLUME ["/radicale/etc", "/radicale/var"]

# :: Monitor
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
USER radicale
ENTRYPOINT ["/usr/bin/python3", "-m", "radicale", "--config", "/radicale/etc/default.conf"]