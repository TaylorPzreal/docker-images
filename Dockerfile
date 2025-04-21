FROM docker.1ms.run/library/ubuntu:22.04

# Set environment variable to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Optional: Define Node.js major version (e.g., 20, 18)
ARG NODE_MAJOR=16.20.02
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
  wget

# Install Node.js using NodeSource repository
RUN apt-get update && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
  apt-get update && \
  apt-get install -y nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install Python 3 essentials
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  python3-pip \
  python3-venv \
  python-is-python3 && \
  # Upgrade pip using a Chinese mirror
  python3 -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Verify installations
RUN echo "Verifying installations..." && \
  node -v && \
  npm -v && \
  python --version && \
  pip --version
