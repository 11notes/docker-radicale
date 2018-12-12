# ------ HEADER ------ #
FROM alpine:3.8

# ------ RUN  ------ #
RUN apk add --update  --no-cache python3 apache2-utils \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip setuptools

RUN /usr/bin/python3 -m pip install --upgrade radicale

RUN apk add --update --no-cache --virtual .dep_bcrypt python3-dev gcc g++ libffi-dev \
    && /usr/bin/python3 -m pip install --upgrade radicale[bcrypt] \
    && apk del .dep_bcrypt

RUN mkdir -p /radicale/etc \
    && mkdir -p /radicale/var \
    && mkdir -p /home/radicale

RUN addgroup --gid 1000 -S radicale \
	&& adduser --uid 1000 -D -S -h /home/radicale -s /sbin/nologin -G radicale radicale

RUN chown -R radicale:radicale /radicale

ADD ./source/radicale.conf /radicale/etc/default.conf
ADD ./source/rights.conf /radicale/etc/rights
ADD ./source/users.bcrypt /radicale/etc/users

# ------ VOLUMES ------ #
VOLUME ["/radicale/etc", "/radicale/var"]

# ------ CMD/START/STOP ------ #
USER radicale:radicale
ENTRYPOINT ["/usr/bin/python3", "-m", "radicale", "--config", "/radicale/etc/default.conf"]