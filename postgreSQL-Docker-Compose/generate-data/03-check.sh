#!/usr/bin/env bash

export PGPASSWORD=postgres
psql -h localhost -U "prgs-docker-app" -d "prgs-docker" <<EOF
SELECT * FROM person;
EOF
