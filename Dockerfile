FROM docker.1ms.run/library/ubuntu:22.04

# Set environment variable to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

RUN pwd
RUN ls -la /home
