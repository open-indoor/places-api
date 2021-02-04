#!/bin/bash
set -x
set -e

export PLACES_API_LOCAL_PORT=${PLACES_API_LOCAL_PORT:-80}
export APP_URL=${APP_URL:-https://${APP_DOMAIN_NAME}}

chmod +x /places/places
cd /places

# cat /etc/caddy/Caddyfile_ | envsubst > /etc/caddy/Caddyfile
cat /etc/caddy/Caddyfile

# Should wait until dat is ready ?
until nmap openindoor-db | grep 5432; do
  echo "Waiting for postgres server..."
  sleep 1
done

PGPASSWORD=${POSTGRES_PASSWORD} psql -h openindoor-db -d ${POSTGRES_DB} -U ${POSTGRES_USER} <<- "EOF"
-- DROP TABLE IF EXISTS "places";
-- DROP SEQUENCE IF EXISTS places_ogc_fid_seq;
CREATE SEQUENCE IF NOT EXISTS places_ogc_fid_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;
CREATE TABLE IF NOT EXISTS "public"."places" (
    "ogc_fid" integer DEFAULT nextval('places_ogc_fid_seq') NOT NULL,
    "id" character varying,
    "wkb_geometry" geometry(Polygon,4326),
    CONSTRAINT "places_pkey" PRIMARY KEY ("ogc_fid")
) WITH (oids = false);

CREATE INDEX IF NOT EXISTS "places_wkb_geometry_geom_idx" ON "public"."places" USING btree ("wkb_geometry");
ALTER TABLE places
ADD CONSTRAINT constraint_name UNIQUE (id);
EOF

for f in `find /tmp/places -type f -name "*.geojson"`; do
    ogr2ogr \
        -f "PostgreSQL" \
        PG:"dbname='openindoor-db' host='"${POSTGRES_DB}"' port='5432' user='"${POSTGRES_USER}"' password='"${POSTGRES_PASSWORD}"'" \
        ${f} \
        -nln places \
        -skipfailures        

        # -preserve_fid \
        # -overwrite
#  \
        # -lco FID=id \
done

mkdir -p /data/places
cp -r /tmp/places/* /data/places/

(\
  caddy run --watch --config /etc/caddy/Caddyfile\
  & fcgiwrap -f -s unix:/var/run/fcgiwrap.socket\
  & env FLASK_APP=places-flask.py flask run\
)
