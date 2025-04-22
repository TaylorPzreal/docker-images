FROM docker.1ms.run/library/ubuntu:22.04

USER root

# Set environment variable to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

RUN pwd
RUN ls -la /home
RUN ls -la /root

# Define the mirror URL base. Choose one:
# Aliyun: http://mirrors.aliyun.com/ubuntu
# Tsinghua: http://mirrors.tuna.tsinghua.edu.cn/ubuntu
# USTC: http://mirrors.ustc.edu.cn/ubuntu
ARG MIRROR_URL=http://mirrors.aliyun.com/ubuntu
# Note: Some mirrors might require http vs https

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

RUN ls -la /etc/ssh

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV /home/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# -----------------------------------------------------------------------------------------

# Optional: Define Node.js major version (e.g., 20, 18)
ARG NODE_VERSION=16.20.2

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update && apt-get install -y nodejs

# -----------------------------------------------------------------------------------------
# 不要使用 nvm 安装nodejs，因为 nvm 安装的nodejs版本会有权限问题，导致
# npm i -g lerna@6.6.2
# npm ERR! code 127
# npm ERR! path /root/.nvm/versions/node/v16.20.2/lib/node_modules/lerna/node_modules/@parcel/watcher
# npm ERR! command failed
# npm ERR! command sh -c -- node-gyp-build
# npm ERR! sh: 1: node-gyp-build: Permission denied
# -----------------------------------------------------------------------------------------

# # install nvm
# COPY /images/ubuntu2204/nvm-install.sh /root/nvm-install.sh
# RUN chmod +x /root/nvm-install.sh
# RUN /root/nvm-install.sh

# # set env
# ENV NVM_DIR=/root/.nvm

# RUN cat /root/.bashrc

# RUN source /root/.bashrc

# # 安装 Node.js 并创建全局符号链接
# RUN . $NVM_DIR/nvm.sh && \
#   nvm install $NODE_VERSION && \
#   nvm alias default $NODE_VERSION && \
#   nvm use default && \
#   ln -sf $(. $NVM_DIR/nvm.sh && nvm which default) /usr/local/bin/node && \
#   ln -sf /usr/local/bin/node /usr/local/bin/nodejs && \
#   ln -sf $(dirname $(. $NVM_DIR/nvm.sh && nvm which default))/npm /usr/local/bin/npm && \
#   ln -sf $(dirname $(. $NVM_DIR/nvm.sh && nvm which default))/npx /usr/local/bin/npx

# # 添加 NODE_PATH 环境变量以确保全局模块可用
# ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
# ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# 验证安装
RUN node -v && npm -v
