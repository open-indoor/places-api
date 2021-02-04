################ PLACES #####################
FROM debian:testing

RUN apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive \
  apt-get -y install --no-install-recommends \
    ca-certificates \
  && apt-get clean

RUN echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" \
    | tee -a /etc/apt/sources.list.d/caddy-fury.list
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y update \
    && apt-get -y install \
      --no-install-recommends \
      bash \
      caddy \
      cron \
      curl \
      fcgiwrap \
      file \
      gettext \
      git \
      grep \
      htop \
      jq \
      less \
      net-tools \
      nmap \
      osmium-tool \
      procps \
      unzip \
      util-linux \
      uuid-runtime \
      vim \
      wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y update \
    && apt-get -y install \
      --no-install-recommends \
      gdal-bin \
      postgresql-client \
      python3-wheel \
      python3-geopandas \
      python3-geojson \
      python3-pycurl \
      python3-pip \
      python3-rtree \
      python3-pyosmium \
      python3-requests \
      python3-flask \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /places
COPY ./requirements.txt /places/
RUN pip3 install -r /places/requirements.txt

COPY ./Caddyfile /etc/caddy/Caddyfile

WORKDIR /places

ENV API_DOMAIN_NAME api.openindoor.io
ENV APP_DOMAIN_NAME app.openindoor.io

COPY ./places-api.sh /places/places-api.sh
RUN chmod +x /places/places-api.sh
COPY ./data/ /tmp/places/
COPY ./places.py /places/places
COPY ./places-flask.py /places/places-flask.py

CMD bash -c "/places/places-api.sh"

EXPOSE 80
EXPOSE 5000