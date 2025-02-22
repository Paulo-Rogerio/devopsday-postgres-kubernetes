export PGPASSWORD=postgres
psql -h localhost -U postgres -d "prgs-docker" <<EOF
CREATE ROLE "prgs-publisher" LOGIN SUPERUSER;
SET ROLE "prgs-publisher";
CREATE PUBLICATION "docker" FOR ALL TABLES;
SELECT * FROM pg_create_logical_replication_slot('docker', 'pgoutput');
EOF
