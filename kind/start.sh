#!/usr/bin/env bash
red='\033[0;31m'
yellow="\033[33m"
endColor="\033[0m"

cd $(dirname $0)

read -p "Informe o Nome do Cluster: " clusterName

if [[ -z ${clusterName} ]]
then
    echo "${red} Cluster Name não informado. ${endColor}"
    exit 1;
fi

echo "${yellow} Start ClusterName ${clusterName} ${endColor}" 

export clusterName

colima_running=$(jq -r .status <<< $(colima list -j))

[[ ${colima_running} == "Stopped" || -z ${colima_running} ]] && colima start --vm-type=vz --network-address --cpu 2 --memory 2 --disk 40

colima ssh -- bash -c "sudo -h 127.0.0.1 -i cat >> /tmp/sysctl.conf <<EOF
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 512
EOF"

colima ssh -- bash -c "sudo -h 127.0.0.1 -i mv /tmp/sysctl.conf /etc/sysctl.conf"

colima ssh -- bash -c "sudo -h 127.0.0.1 -i /usr/sbin/sysctl -p"

envsubst < k8s/cluster.yaml > k8s/tmp/cluster.yaml
sh k8s/create-cluster.sh
