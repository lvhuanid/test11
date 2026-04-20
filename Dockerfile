# 基础镜像
FROM registry.cn-hangzhou.aliyuncs.com/zenithtel/debian:amd AS runtime


ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    echo "root:123456" | chpasswd && \
    sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config && \
    (id -u cli >/dev/null 2>&1 && userdel -f cli || true) && \
    (getent group cli >/dev/null 2>&1 && groupdel cli || true) && \
    groupadd cli && \
    useradd -g cli -m -d /home/cli -s /bin/sh cli && \
    echo "cli:123456" | chpasswd && \
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