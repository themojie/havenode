#一键部署和下载脚本的命令

bash <(curl -Ls https://raw.githubusercontent.com/themojie/supernode/main/install.sh)

wget https://raw.githubusercontent.com/themojie/supernode/main/install.sh

# 新增的参数

superman_api_url=wss://xxx.com   // superman 需要用 websocket 通信，wss或ws，取决于是否启用了tls
superman_api_key=asd
superman_user_cache_time=30      // 缓存用户时间，单位：天
domain_sniff=tls,http,ssh    //ssh就是禁用ssh
