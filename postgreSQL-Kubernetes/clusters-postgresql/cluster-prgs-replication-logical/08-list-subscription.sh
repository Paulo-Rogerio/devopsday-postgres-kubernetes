#!/usr/bin/env bash

export PGPASSWORD=$(kubectl get secret -n prgs prgs-k8s-superuser -o jsonpath="{.data.password}" | base64 -d | xargs)
ipLoadbalancer=$(kubectl get svc/prgs-k8s-external-rw -n prgs -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

psql -p 5000 -U postgres -h ${ipLoadbalancer} -d "prgs-docker" << EOF
\x
select * from pg_subscription;
EOF


