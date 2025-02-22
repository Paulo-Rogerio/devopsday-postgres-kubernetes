export PGPASSWORD=postgres

psql -h localhost -U postgres -d "prgs-docker" -c "select count(*) from person;"

read -p "Start Range: " range_start
read -p "Start End  : " range_end

psql -h localhost -U postgres -d "prgs-docker" -v range_start=${range_start} -v range_end=${range_end} <<EOF
INSERT INTO person (
 first_name,
 last_name,
 nationality,
 birthday,
 photo_id
)
SELECT
  initcap(base26_encode(substring(random()::text,3,10)::bigint)) AS first_name
, initcap(base26_encode(substring(random()::text,3,15)::bigint)) AS last_name
, initcap(base26_encode(substring(random()::text,3,9)::bigint)) AS nationality
, 'now'::date - (interval '90 years' * random()) AS birthday
, ceil(random()*2100000000) AS photo_id
FROM generate_series(:range_start,:range_end) num;
EOF
