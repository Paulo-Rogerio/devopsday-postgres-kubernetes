#!/usr/bin/env bash

red=$'\e[31;01m'
green=$'\e[32;01m'
reset=$'\e[0m'

export PGPASSWORD=$(kubectl get secret prgs-k8s-superuser -n prgs -o  jsonpath="{.data.password}" | base64 -d | xargs)

ipLoadbalancer=$(kubectl get svc/prgs-k8s-external-rw -n prgs -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

function sqlVerifyLSNK8s(){
  psql \
  -p 5000 \
  -h ${ipLoadbalancer} \
  -U postgres \
  -d "prgs-docker" -At <<-EOF
  SELECT received_lsn from pg_stat_subscription
EOF
}

function sqlVerifyLSNDocker(){
  psql \
  -p 5432 \
  -h localhost \
  -U postgres \
  -d "prgs-docker" -At <<EOF
  SELECT CASE WHEN NOT pg_is_in_recovery() THEN pg_current_wal_lsn() ELSE COALESCE(pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn()) END
EOF
}

until [[ $(sqlVerifyLSNDocker) == $(sqlVerifyLSNK8s) ]]
do
    echo "${red} Cluster Desincronizados ${reset}"
    sleep 2
done

echo "======================================="
echo "${green} Cluster Sincronizados ${reset}"
echo "LSN Docker    : $(sqlVerifyLSNDocker)"
echo "LSN Kubernetes: $(sqlVerifyLSNK8s)"
echo "======================================="