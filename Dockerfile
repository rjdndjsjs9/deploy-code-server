# Use a base image of your choice
FROM debian:bullseye-slim

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sudo \
    systemd \
    dbus \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    gnupg \
    software-properties-common && \
    apt-get clean

# Install Docker (optional if you want Docker-in-Docker)
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Install Docker Compose (optional for Docker management)
RUN curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(lsb_release -cs)-x86_64 -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Set environment variables for UID and to force Docker container to run as root
ENV RAILWAY_RUN_UID=0

# Set up systemd init system
ENV container=docker

# Install rclone for remote filesystem support (optional)
RUN curl https://rclone.org/install.sh | bash

# Set working directory
WORKDIR /home/coder

# Setup volume mount points to persist data
# The following lines assume you want to create volumes for your app data, logs, and config
VOLUME ["/mnt/data", "/mnt/config", "/mnt/logs"]

# Make sure the user 'coder' has correct permissions for these volumes
RUN chown -R coder:coder /mnt/data /mnt/config /mnt/logs

# Install any other dependencies or tools
RUN apt-get install -y vim git build-essential

# Set the default shell to bash
ENV SHELL=/bin/bash

# Expose necessary ports (example port 8080)
EXPOSE 8080

# Add a script to act as an entry point for the container
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Set the entrypoint to a custom script or systemd
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/sbin/init"]

# Ensure that the container stays alive
STOPSIGNAL SIGTERM
