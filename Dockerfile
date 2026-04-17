# 你要求的基础镜像（阿里云 Debian amd 架构）
FROM registry.cn-hangzhou.aliyuncs.com/zenithtel/debian:amd AS runtime

# 避免安装时弹窗
ENV DEBIAN_FRONTEND=noninteractive

# 安装 SSH 服务 + 配置
RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    echo "root:123456" | chpasswd && \
    sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config

# 暴露 SSH 端口 22
EXPOSE 22

# 启动 SSH 服务
CMD ["/usr/sbin/sshd", "-D"]


# docker build --platform linux/amd64 -t debian-ssh .

# docker run -d -p 2222:22 --name my-debian-ssh debian-ssh

# ssh root@localhost -p 2222

# 密码：123456