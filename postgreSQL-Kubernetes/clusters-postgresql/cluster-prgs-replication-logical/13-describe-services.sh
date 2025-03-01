#!/usr/bin/env bash
yellow="\033[33m"
endColor="\033[0m"

echo "${yellow} ===================== Endpoints ========================= ${endColor}"
kubectl get endpoints -n prgs
echo
echo
echo "${yellow} ============= Services RW ( ClusterIP ) ================= ${endColor}"
kubectl describe service prgs-k8s-rw -n prgs
echo
echo
echo "${yellow} ============ Services RW ( LoadBalancer ) =============== ${endColor}"
kubectl describe service prgs-k8s-external-rw -n prgs
echo
echo
echo "${yellow} ============= Services RO ( ClusterIP ) ================= ${endColor}"
kubectl describe service prgs-k8s-ro -n prgs
echo
echo
echo "${yellow} ============ Services R0 ( LoadBalancer ) =============== ${endColor}"
kubectl describe service prgs-k8s-external-ro -n prgs
