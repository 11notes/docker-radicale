# ------ HEADER ------ #
FROM alpine:3.7

# ------ RUN  ------ #
RUN apk add --update  --no-cache python3 apache2-utils \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip setuptools

RUN /usr/bin/python3 -m pip install --upgrade radicale

RUN apk add --update --no-cache --virtual .dep_bcrypt python3-dev gcc g++ libffi-dev \
    && /usr/bin/python3 -m pip install --upgrade radicale[bcrypt] \
    && apk del .dep_bcrypt

RUN mkdir -p /data \
    && mkdir -p /config

ADD ./source/radicale.conf /config/default.conf
ADD ./source/rights.conf /config/rights
ADD ./source/users.bcrypt /config/users

# ------ VOLUMES ------ #
VOLUME ["/data", "/config"]

# ------ CMD/START/STOP ------ #
ENTRYPOINT ["/usr/bin/python3", "-m", "radicale", "--config", "/config/default.conf"]