#!/usr/bin/env bash

kubectl cnpg publication create prgs-k8s -n prgs \
  --external-cluster docker \
  --publication docker \
  --dbname prgs-docker \
  --all-tables

echo "Sleep 5 seconds..."
sleep 5

kubectl cnpg subscription create prgs-k8s -n prgs \
  --external-cluster docker \
  --publication docker \
  --subscription docker \
  --dbname prgs-docker
