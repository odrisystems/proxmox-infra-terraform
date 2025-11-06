#!/bin/bash

# set -e

sudo apt update -y && apt upgrade -y
sudo apt install -y htop apt-transport-https ca-certificates curl gnupg-agent software-properties-common qemu-guest-agent jq zip unzip gnupg sshpass

# Variables
VERSION="8.12.2"
DEB_FILE="filebeat-${VERSION}-amd64.deb"
DOWNLOAD_URL="https://artifacts.elastic.co/downloads/beats/filebeat/${DEB_FILE}"
CUSTOM_CONFIG="filebeat.yml"
DEST_CONFIG="/etc/filebeat/filebeat.yml"
DEST_WORKING_DIR="/etc/filebeat"

echo "[INFO] Starting Filebeat $VERSION installation..."


# Download Filebeat .deb
echo "[INFO] Downloading Filebeat from $DOWNLOAD_URL"
sudo wget  "$DOWNLOAD_URL"


# Install Filebeat
if ! sudo dpkg -i "$DEB_FILE"; then
  echo "[WARN] dpkg failed, attempting to fix with apt-get..."
  sudo apt-get install -f -y
fi

# Ensure config directory exists
sudo mkdir -p "$DEST_WORKING_DIR"


# Copy config
echo "[INFO] Copying custom config..."
sudo cp -v "$CUSTOM_CONFIG" "$DEST_CONFIG"
sudo chown root:root "$DEST_CONFIG"
sudo chmod 600 "$DEST_CONFIG"


# Enable and start Filebeat
echo "[INFO] Enabling and starting Filebeat service..."
sudo systemctl enable filebeat
sudo systemctl start filebeat
sudo systemctl status filebeat --no-pager

# Clean up
echo "[INFO] Cleaning up downloaded .deb file..."
sudo rm -f "$DEB_FILE"

echo "[SUCCESS] Filebeat $VERSION installed and configured successfully."

