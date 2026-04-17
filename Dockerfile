# 基础镜像
FROM registry.cn-hangzhou.aliyuncs.com/zenithtel/debian:amd AS runtime

# 避免安装时弹窗
ENV DEBIAN_FRONTEND=noninteractive

# 安装 SSH 服务
RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    # --- 1. 配置 root 登录 ---
    echo "root:123456" | chpasswd && \
    sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config && \
    # --- 2. 清理并重新创建 cli 用户组和用户 ---
    # 使用 id 命令检查是否存在，避免初次构建时 del 命令报错
    (id -u cli >/dev/null 2>&1 && userdel -f cli || true) && \
    (getent group cli >/dev/null 2>&1 && groupdel cli || true) && \
    groupadd cli && \
    useradd -g cli -m -d /home/cli -s /bin/sh cli && \
    echo "cli:123456" | chpasswd && \
    # --- 3. 追加 SSH 配置规则 ---
    # 注意：Match 规则通常建议放在文件末尾
    cat >> /etc/ssh/sshd_config << 'EOF'

Match Group cli
    ForceCommand /usr/bin/cli-proxy
    PermitTTY yes
    ChrootDirectory none
    AllowTcpForwarding no
    X11Forwarding no
EOF

# 暴露 SSH 端口
EXPOSE 22

# 启动 SSH 服务（此步会自动加载上面追加的配置）
CMD ["/usr/sbin/sshd", "-D"]

# ssh-keygen -R "[localhost]:2222" 清楚除本地已存在的 SSH 主机密钥，避免连接时出现警告