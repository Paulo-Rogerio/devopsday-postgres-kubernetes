#!/usr/bin/env bash

kubectl cnpg subscription drop prgs-k8s \
    -n prgs \
    --subscription "docker" \
    --dbname "prgs-docker"
