#!/usr/bin/env bash
set -e

psql -v ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" <<-EOSQL

CREATE SCHEMA IF NOT EXISTS ${APP_DB_SCHEMA};

CREATE ROLE ${APP_DB_USER}
    LOGIN
    PASSWORD '${APP_DB_PASSWORD}';

ALTER ROLE ${APP_DB_USER} SET search_path = ${APP_DB_SCHEMA}, public;

DO \$\$
DECLARE
    s text;
    app_user text := '${APP_DB_USER}';
BEGIN
    FOR s IN
        SELECT nspname
        FROM pg_namespace
        WHERE nspname NOT IN ('pg_catalog', 'information_schema')
          AND nspname NOT LIKE 'pg_toast%%'
    LOOP
        EXECUTE format('GRANT USAGE ON SCHEMA %I TO %I;', s, app_user);

        EXECUTE format(
            'GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %I TO %I;',
            s, app_user
        );

        EXECUTE format(
            'GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA %I TO %I;',
            s, app_user
        );

        EXECUTE format(
            'ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I;',
            s, app_user
        );
        EXECUTE format(
            'ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT USAGE, SELECT ON SEQUENCES TO %I;',
            s, app_user
        );
    END LOOP;
END
\$\$;

EOSQL
