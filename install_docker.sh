#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
DOCKER_DATA_ROOT="/mnt/cache/docker"
DAEMON_JSON="/etc/docker/daemon.json"
TARGET_USER="${SUDO_USER:-$USER}"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use: sudo ./install_docker.sh)" >&2
    exit 1
fi

# --- Ensure cache dir exists ---
mkdir -p "$DOCKER_DATA_ROOT"

# --- Add Docker's official GPG key ---
apt update
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# --- Add the repository to Apt sources ---
tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
apt update

# --- Install Docker packages ---
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Stop docker before changing data-root ---
systemctl stop docker.service docker.socket 2>/dev/null || true

# --- Migrate any existing data before repointing data-root ---
if [ -d /var/lib/docker ] && [ -n "$(ls -A /var/lib/docker 2>/dev/null)" ] && [ ! -d "$DOCKER_DATA_ROOT/image" ]; then
    echo "Migrating existing /var/lib/docker contents to $DOCKER_DATA_ROOT ..."
    rsync -aP /var/lib/docker/ "$DOCKER_DATA_ROOT/"
fi

# --- Write daemon.json with new data-root (merge if file already exists) ---
if [ -f "$DAEMON_JSON" ]; then
    python3 - "$DAEMON_JSON" "$DOCKER_DATA_ROOT" <<'EOF'
import json, sys
path, data_root = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        config = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    config = {}
config["data-root"] = data_root
with open(path, "w") as f:
    json.dump(config, f, indent=2)
EOF
else
    mkdir -p "$(dirname "$DAEMON_JSON")"
    cat > "$DAEMON_JSON" <<EOF
{
  "data-root": "$DOCKER_DATA_ROOT"
}
EOF
fi

# --- Restart docker with new config ---
systemctl daemon-reload
systemctl enable docker.service
systemctl start docker.service

# --- Post-install: allow running docker without sudo ---
groupadd docker 2>/dev/null || true
usermod -aG docker "$TARGET_USER"

echo ""
echo "Docker installed. data-root set to: $DOCKER_DATA_ROOT"
echo "Verify with: docker info -f '{{ .DockerRootDir }}'"
echo ""
echo "User '$TARGET_USER' was added to the docker group."
echo "Log out and back in (or run 'newgrp docker') for it to take effect in your shell."
