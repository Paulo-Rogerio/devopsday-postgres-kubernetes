#!/usr/bin/env bash

export PGPASSWORD=$(kubectl get secret prgs-k8s-superuser -n prgs -o  jsonpath="{.data.password}" | base64 -d | xargs)

ipLoadbalancer=$(kubectl get svc/prgs-k8s-external-rw -n prgs -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

psql \
  -p 5000 \
  -h ${ipLoadbalancer} \
  -U "prgs-docker-app" \
  -d "prgs-docker" \
  -c "select setval('person_id_seq', (select MAX(id) FROM person));"
