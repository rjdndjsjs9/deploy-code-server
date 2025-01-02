# Start from the code-server Debian base image
FROM codercom/code-server:4.9.0

USER root

# Install systemd and dependencies for running systemd in the container
RUN apt-get update && apt-get install -y \
    systemd \
    systemd-sysv \
    dbus \
    sudo \
    curl \
    unzip && \
    apt-get clean

# Enable systemd inside the container by setting the necessary environment variables
ENV container=docker

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN curl https://rclone.org/install.sh | bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# RUN code-server --install-extension esbenp.prettier-vscode

# Install apt packages:
# RUN apt-get install -y ubuntu-make

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------

# Set up the systemd init system to run with the container
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/sbin/init"]

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
