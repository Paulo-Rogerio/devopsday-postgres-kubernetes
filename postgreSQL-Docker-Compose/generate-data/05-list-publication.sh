export PGPASSWORD=postgres
psql -h localhost -U postgres -d "prgs-docker" <<EOF
SELECT * FROM pg_publication;
SELECT * FROM pg_replication_slots;
EOF
