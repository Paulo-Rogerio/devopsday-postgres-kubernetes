#!/usr/bin/env bash

export PGPASSWORD=$(kubectl get secret prgs-k8s-superuser -n prgs -o  jsonpath="{.data.password}" | base64 -d | xargs)

ipLoadbalancer=$(kubectl get svc/prgs-k8s-external-rw -n prgs -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

read -p "Start Range: " range_start
read -p "Start End  : " range_end

psql \
  -p 5000 \
  -h ${ipLoadbalancer} \
  -U postgres \
  -d "prgs-docker" \
  -v range_start=${range_start} \
  -v range_end=${range_end} <<EOF
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
