#!/usr/bin/env bash

export PGPASSWORD=postgres
psql -h localhost -U postgres -d postgres <<EOF
CREATE ROLE "prgs-docker-app" LOGIN PASSWORD 'postgres';
CREATE DATABASE "prgs-docker" OWNER "prgs-docker-app";
EOF

psql -h localhost -U postgres -d "prgs-docker" <<EOF
BEGIN;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE CREATE ON DATABASE "prgs-docker" FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO "prgs-docker-app";
ALTER DEFAULT PRIVILEGES GRANT SELECT,INSERT,UPDATE,DELETE ON TABLES TO "prgs-docker-app";
ALTER DEFAULT PRIVILEGES GRANT USAGE, SELECT ON SEQUENCES TO "prgs-docker-app";
ALTER DEFAULT PRIVILEGES GRANT EXECUTE ON FUNCTIONS TO "prgs-docker-app";
ALTER DEFAULT PRIVILEGES GRANT USAGE ON SCHEMAS TO "prgs-docker-app";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "prgs-docker-app";
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO "prgs-docker-app";
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO "prgs-docker-app";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "prgs-docker-app";
CREATE SCHEMA IF NOT EXISTS prgs_docker AUTHORIZATION "prgs-docker-app";
ALTER DATABASE "prgs-docker" SET search_path = prgs_docker, public;
COMMIT;
EOF

psql -h localhost -U "prgs-docker-app" -d "prgs-docker" <<EOF
CREATE TABLE person (
    id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    nationality TEXT,
    birthday DATE,
    photo_id INTEGER UNIQUE
);

CREATE OR REPLACE FUNCTION base26_encode(IN digits bigint, IN min_width int = 0)
  RETURNS varchar AS \$\$
        DECLARE
          chars char[];
          ret varchar;
          val bigint;
      BEGIN
      chars := ARRAY['A','B','C','D','E','F','G','H','I','J','K','L','M'
                    ,'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
      val := digits;
      ret := '';
      IF val < 0 THEN
          val := val * -1;
      END IF;
      WHILE val != 0 LOOP
          ret := chars[(val % 26)+1] || ret;
          val := val / 26;
      END LOOP;

      IF min_width > 0 AND char_length(ret) < min_width THEN
          ret := lpad(ret, min_width, '0');
      END IF;

      RETURN ret;

END;
\$\$ LANGUAGE 'plpgsql' IMMUTABLE;
EOF

