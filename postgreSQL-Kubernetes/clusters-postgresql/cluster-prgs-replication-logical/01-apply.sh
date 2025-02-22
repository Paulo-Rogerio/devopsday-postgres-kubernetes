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

kubectl apply -f cluster-prgs-k8s.yaml
check_pod_running

kubectl apply -f cluster-prgs-k8s-rw.yaml

