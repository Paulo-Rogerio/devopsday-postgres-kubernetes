#!/usr/bin/env bash

export PGPASSWORD=postgres
count=0
working=true

ipLoadbalancer=$(kubectl get svc/prgs-k8s-external-rw -n prgs -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
psql \
  -p 5000 \
  -h ${ipLoadbalancer} \
  -U postgres \
  -d "prgs-docker" -At <<EOF
  ALTER SUBSCRIPTION docker DISABLE;
EOF

while ${working}
do
    [[ ${count} -eq 300 ]] && export working=false 
    psql \
        -h localhost \
        -U postgres \
        -d "prgs-docker" -At <<EOF
        SELECT * FROM person FOR UPDATE;
EOF
    ((count++))
    echo "Job Update Item: ${count}"
done

psql \
  -p 5000 \
  -h ${ipLoadbalancer} \
  -U postgres \
  -d "prgs-docker" -At <<EOF
  ALTER SUBSCRIPTION docker ENABLE;
EOF


