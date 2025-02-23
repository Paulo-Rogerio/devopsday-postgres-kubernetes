#!/usr/bin/env bash

echo "============= Services RW ( ClusterIP ) ================="
kubectl describe service prgs-k8s-rw -n prgs
echo
echo
echo "============ Services RW ( LoadBalancer ) ==============="
kubectl describe service prgs-k8s-external-rw -n prgs
echo
echo
echo "===================== Endpoints ========================="
kubectl get endpoints -n prgs
