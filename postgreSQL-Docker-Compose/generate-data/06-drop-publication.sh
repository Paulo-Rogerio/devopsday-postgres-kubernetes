export PGPASSWORD=postgres
psql -h localhost -U postgres -d "prgs-docker" <<EOF
DROP PUBLICATION "docker";
SELECT pg_drop_replication_slot('docker');
DROP ROLE "prgs-publisher";
EOF
