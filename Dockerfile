################ PLACES #####################
FROM caddy:2-alpine

RUN apk add --update-cache \
    bash \
    curl \
    jq \
    fcgiwrap \
    gettext \
    grep \
    htop \
    net-tools \
    vim \
    util-linux \
    python3 py3-pip geos geos-dev py3-wheel py3-scipy curl-dev gcc musl-dev \
    && rm -rf /var/cache/apk/*
    
COPY ./requirements.txt /places/
RUN pip install -r /places/requirements.txt

COPY ./Caddyfile /etc/caddy/Caddyfile_

RUN mkdir -p /places-api

WORKDIR /places

ENV API_DOMAIN_NAME api.openindoor.io
ENV APP_DOMAIN_NAME app.openindoor.io

CMD bash -c "/places/places-api.sh"

EXPOSE 80

COPY ./places-api.sh /places/places-api.sh
RUN chmod +x /places/places-api.sh
COPY ./places.py /places/places
COPY ./data/ /tmp/places/

