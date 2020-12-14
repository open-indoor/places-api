#!/bin/bash
set -x
set -e

export PLACES_API_LOCAL_PORT=${PLACES_API_LOCAL_PORT:-80}
export APP_URL=${APP_URL:-https://${APP_DOMAIN_NAME}}

chmod +x /places/places

mkdir -p /data/places

cp -r /tmp/places/* /data/places/

cat /etc/caddy/Caddyfile_ | envsubst > /etc/caddy/Caddyfile
cat /etc/caddy/Caddyfile

(caddy run --watch --config /etc/caddy/Caddyfile & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket)
