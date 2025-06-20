#!/bin/bash
# 检测并启用 BBR 的脚本，包含内核支持检测和配置文件备份
# 适用于 Debian 10+, Ubuntu 18+ 等支持 BBR 的系统

# 检查是否以 root 权限运行
if [[ $EUID -ne 0 ]]; then
    echo "错误：请以 root 权限运行此脚本（使用 sudo）"
    exit 1
fi

# 检查内核版本是否支持 BBR
KERNEL_VERSION=$(uname -r)
MIN_KERNEL="4.9"
if [[ $(echo -e "$KERNEL_VERSION\n$MIN_KERNEL" | sort -V | head -n1) != "$MIN_KERNEL" ]]; then
    echo "当前内核版本 ($KERNEL_VERSION) 支持 BBR，继续处理..."
else
    echo "错误：当前内核版本 ($KERNEL_VERSION) 低于 4.9，不支持 BBR"
    echo "建议升级内核到 4.9 或更高版本"
    exit 1
fi

# 获取当前拥塞控制算法状态
if grep -q 'bbr' /proc/sys/net/ipv4/tcp_congestion_control; then
    echo "BBR 已启用，无需重复配置"
else
    echo "正在启用 BBR..."

    # 备份 /etc/sysctl.conf
    if [[ -f /etc/sysctl.conf ]]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        cp /etc/sysctl.conf /etc/sysctl.conf.bak.$timestamp
        if [[ $? -eq 0 ]]; then
            echo "已备份 /etc/sysctl.conf 到 /etc/sysctl.conf.bak.$timestamp"
        else
            echo "错误：备份 /etc/sysctl.conf 失败，请检查权限或磁盘空间"
            exit 1
        fi
    fi

    # 添加配置，避免重复写入
    grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf || echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    grep -q "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf || echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

    # 应用配置并检查是否成功
    if sysctl -p >/dev/null 2>&1; then
        echo "BBR 已成功启用"
    else
        echo "错误：应用 sysctl 配置失败，请检查 /etc/sysctl.conf 文件"
        exit 1
    fi

    # 验证 BBR 是否真的启用
    if grep -q 'bbr' /proc/sys/net/ipv4/tcp_congestion_control; then
        echo "验证：BBR 已成功运行"
    else
        echo "警告：BBR 配置未生效，可能需要重启或进一步检查"
        exit 1
    fi
fi

# 输出当前网络队列和拥塞控制状态
echo -e "\n当前配置状态："
echo "队列规则 (default_qdisc): $(sysctl -n net.core.default_qdisc)"
echo "拥塞控制算法 (tcp_congestion_control): $(sysctl -n net.ipv4.tcp_congestion_control)"
