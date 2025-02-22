#!/usr/bin/env bash
cd $(dirname $0)

function check_pod_running(){
    todo=true
    while ${todo};
    do
      podsWorking=$(kubectl get pod -A -o custom-columns="STATUS:.status.phase" | grep -v STATUS | egrep -vc "Running|Succeeded")
      [[ ${podsWorking} == 0 ]] && export todo=false
      echo "Waiting Pod Health..."
      sleep 10
    done
    echo "Pods Running"
}

[[ $(kind get clusters) == "${clusterName}" ]] || kind create cluster --config=tmp/cluster.yaml
check_pod_running

kubectl label nodes ${clusterName}-worker kubernetes.io/role=worker-apps
kubectl label nodes ${clusterName}-worker2 kubernetes.io/role=worker-postgres

echo "Install Metallb..."
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb --namespace metallb-system --create-namespace
check_pod_running

# CIDR Metallb
echo "Apply Metallb..."
source metallb.sh

kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
check_pod_running

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml
check_pod_running

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install --namespace kube-system --create-namespace metrics-server metrics-server/metrics-server -f values/metric-server.yaml
check_pod_running

loadBalancerIP=$(kubectl get services \
   --namespace ingress-nginx \
   ingress-nginx-controller \
   --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo
echo "---------------------"
echo
curl ${loadBalancerIP}/foo
echo
echo "---------------------"
echo
curl ${loadBalancerIP}/bar
echo   
echo "---------------------"
echo

kubectl delete -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml

# Clean tmp files
rm tmp/cluster.yaml
rm tmp/metallb.yaml
