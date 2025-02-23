#!/usr/bin/env bash

export PGPASSWORD=postgres
psql -h localhost -U postgres -d postgres <<EOF
CREATE DATABASE "prgs-docker";
EOF

psql -h localhost -U postgres -d "prgs-docker" <<EOF
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

