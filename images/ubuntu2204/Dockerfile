FROM docker.1ms.run/library/ubuntu:22.04

USER root

# Set environment variable to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Define the mirror URL base. Choose one:
# Aliyun: http://mirrors.aliyun.com/ubuntu
# Tsinghua: http://mirrors.tuna.tsinghua.edu.cn/ubuntu
# USTC: http://mirrors.ustc.edu.cn/ubuntu
ARG MIRROR_URL=http://mirrors.aliyun.com/ubuntu

RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
  # Replace standard http archive and security URLs
  sed -i "s|http://archive.ubuntu.com/ubuntu|${MIRROR_URL}|g" /etc/apt/sources.list && \
  sed -i "s|http://security.ubuntu.com/ubuntu|${MIRROR_URL}|g" /etc/apt/sources.list && \
  # Also replace potential https URLs if they exist in the base image's list
  sed -i "s|https://archive.ubuntu.com/ubuntu|${MIRROR_URL}|g" /etc/apt/sources.list && \
  sed -i "s|https://security.ubuntu.com/ubuntu|${MIRROR_URL}|g" /etc/apt/sources.list && \
  # Some base images might use ports.ubuntu.com for non-amd64 architectures, replace that too
  sed -i "s|http://ports.ubuntu.com/ubuntu-ports|${MIRROR_URL}|g" /etc/apt/sources.list && \
  sed -i "s|https://ports.ubuntu.com/ubuntu-ports|${MIRROR_URL}|g" /etc/apt/sources.list && \
  # Update package lists using the new mirror
  apt-get update && \
  # Clean up APT cache
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Configure APT to use the specified mirror
# Backup original sources.list first
# Use sed to replace default ubuntu domains with the mirror URL
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  apt-transport-https \
  software-properties-common \
  wget \
  build-essential libssl-dev \
  git \
  openssh-server

# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV /home/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# -----------------------------------------------------------------------------------------

# Optional: Define Node.js version (e.g., 20, 18)
ARG NODE_VERSION=16.20.2

# install nvm
COPY /images/ubuntu2204/nvm-install.sh /root/nvm-install.sh
RUN chmod +x /root/nvm-install.sh
RUN /root/nvm-install.sh

# set env
ENV NVM_DIR=/root/.nvm
RUN cat /root/.bashrc
RUN source /root/.bashrc

# 安装 Node.js
RUN . $NVM_DIR/nvm.sh && \
  nvm install $NODE_VERSION && \
  nvm alias default $NODE_VERSION && \
  nvm use default 

# 添加 NODE_PATH 环境变量以确保全局模块可用
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
# 重制 nvm node 角色，否则 nvm 安装的 node 在安装新的依赖的时候会没有权限
RUN chown -R root: /root

# 验证安装
RUN node -v && npm -v
