export PGPASSWORD=postgres
psql -h localhost -U postgres -d "prgs-docker" <<EOF
SELECT * FROM person;
EOF
