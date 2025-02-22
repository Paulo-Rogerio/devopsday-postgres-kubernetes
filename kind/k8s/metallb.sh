#!/usr/bin/env bash

function output(){
  echo $(date +%Y-%m-%d-%H:%M:%S) - $@
}

export colima_host_ip=$(ifconfig bridge100 | grep "inet " | cut -d' ' -f2)
output "Ip Colima Host............: ${colima_host_ip}"

export colima_vm_ip=$(colima list | grep docker | awk '{print $8}')
output "Ip Colima Vm..............: ${colima_vm_ip}"

export colima_kind_cidr=$(docker network inspect -f '{{.IPAM.Config}}' kind | egrep -o '[0-9]{3}.[0-9]{2}.[0-9].[0-9]/[0-9]{2}')
output "Colima Kind CIDR..........: ${colima_kind_cidr}"

export colima_kind_cidr_short=$(cut -d '.' -f1-2 <<< ${colima_kind_cidr})
output "Colima CIDR short.........: ${colima_kind_cidr_short}"

export colima_vm_iface=$(colima ssh -- bash -c "ip -br address show to ${colima_vm_ip} | cut -d' ' -f1")
output "Colima Vm Iface...........: ${colima_vm_iface}" 

export colima_kind_iface=$(colima ssh -- bash -c "ip -br address show to ${colima_kind_cidr} | cut -d' ' -f1")
output "Colima Kind iface.........: ${colima_kind_iface}"

export colima_iptables="sudo -h 127.0.0.1 iptables -A FORWARD -s ${colima_host_ip} -d ${colima_kind_cidr} -i ${colima_vm_iface} -o ${colima_kind_iface} -p tcp -j ACCEPT"

export iptable_enable=$(colima ssh -- bash -c "sudo -h 127.0.0.1 iptables -nL | grep ${colima_host_ip} | grep -o ACCEPT || echo REJECT")

[[ ${iptable_enable} == "REJECT" ]] && colima ssh -- bash -c "${colima_iptables}" || output "Colima Iptables Enable....: True"

if [[ $(netstat -rn | grep ${colima_kind_cidr_short} >/dev/null 2>&1; echo $?) == 0 ]]
then
  output "Add Rotas.................: Done"
else
  output "Execute Command...........: sudo route -nv add -net ${colima_kind_cidr_short} ${colima_vm_ip}";
  sudo route -nv add -net ${colima_kind_cidr_short} ${colima_vm_ip}
fi

output "Colima LoadBalancer.......: Sucessfully"

envsubst < metallb.yaml > tmp/metallb.yaml

kubectl apply -f tmp/metallb.yaml
