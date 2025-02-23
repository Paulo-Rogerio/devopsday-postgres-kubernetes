#!/usr/bin/env bash

export PGPASSWORD=$(kubectl get secret prgs-k8s-superuser -n prgs -o jsonpath="{.data.password}" | base64 -d | xargs)
ipLoadbalancer=$(kubectl get svc/prgs-k8s-external-ro -n prgs -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

psql -p 5002 -U "prgs-docker-app" -h ${ipLoadbalancer} -d "prgs-docker"


