#!/usr/bin/env bash
cd $(dirname $0)

colima_running=$(jq -r .status <<< $(colima list -j))

kind delete cluster -n $(kind get clusters)

[[ ${colima_running} == "Running" ]] && colima stop


