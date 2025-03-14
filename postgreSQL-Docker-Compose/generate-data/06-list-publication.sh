#!/usr/bin/env bash

export PGPASSWORD=postgres
psql -h localhost -U postgres -d "prgs-docker" <<EOF
\x on;
SELECT * FROM pg_publication;
SELECT * FROM pg_replication_slots;
EOF
