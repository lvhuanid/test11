# 基础镜像
FROM registry.cn-hangzhou.aliyuncs.com/zenithtel/debian:amd AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    # 1. 配置 root
    echo "root:123456" | chpasswd && \
    sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config && \
    # 2. 创建用户（建议在修改配置前完成，逻辑更清晰）
    groupadd -f cli && \
    useradd -g cli -m -d /home/cli -s /bin/sh cli || true && \
    echo "cli:123456" | chpasswd && \
    # 3. 追加 Match Group 规则 (确保 EOF 后面紧跟接续符)
    cat >> /etc/ssh/sshd_config << 'EOF'
Match Group cli
    ForceCommand /usr/bin/cli-proxy
    PermitTTY yes
    ChrootDirectory none
    AllowTcpForwarding no
    X11Forwarding no
EOF

# 暴露端口
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]