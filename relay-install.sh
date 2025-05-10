#!/bin/bash
# 获取参数
GitNodeInstallToken=$1
NezhaAgentToken=$2
AutoUpdateToken=$3
bash <(curl -m 10 -Ls https://$GitNodeInstallToken@raw.githubusercontent.com/themojie/nodeinstall/main/link/relay_node.sh) relay hk
bash /usr/local/cron/cnsync_hk
curl -L https://raw.githubusercontent.com/themojie/nezha-agent-v0/refs/heads/v0-final/install_agent.sh -o install_agent.sh
chmod +x install_agent.sh && ./install_agent.sh 0.20.5 nezha0.qnm.la 443 $NezhaAgentToken
bash <(curl -m 10 -Ls https://$GitNodeInstallToken@raw.githubusercontent.com/themojie/nodeinstall/main/gitup/gitup_install.sh) $AutoUpdateToken /conf/mjnginx.conf