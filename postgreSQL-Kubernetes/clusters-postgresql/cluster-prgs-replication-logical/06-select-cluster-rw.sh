#!/usr/bin/env bash

export PGPASSWORD=$(kubectl get secret prgs-k8s-superuser -n prgs -o  jsonpath="{.data.password}" | base64 -d | xargs)

ipLoadbalancer=$(kubectl get svc/prgs-k8s-external-rw -n prgs -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')


echo "===================== List Tables ========================="
psql -p 5000 -U postgres -h ${ipLoadbalancer} -d "prgs-docker" -c "\dt"
echo
echo
echo "===================== Select Person ======================="
psql -p 5000 -U postgres -h ${ipLoadbalancer} -d "prgs-docker" -c "select * from person;"
echo
echo
echo "===================== Select Person ======================="
psql -p 5000 -U postgres -h ${ipLoadbalancer} -d "prgs-docker" -c "select pg_is_in_recovery();"


