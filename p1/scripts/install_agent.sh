#!/bin/bash

# Update system
apt-get update -y
apt install -y net-tools
apt-get upgrade -y

# Détecte l'interface réseau privée
PRIVATE_IFACE=$(ip -o -4 addr show | awk '/192\.168\.56\./ {print $2; exit}')
echo "Detected private network interface: $PRIVATE_IFACE"

# Wait for the server token to be available
while [ ! -f /vagrant/confs/node-token ]; do
  echo "Waiting for server node-token..."
  sleep 5
done

echo "Node token found. Proceeding with installation..."

# Set variables
K3S_TOKEN=$(cat /vagrant/confs/node-token)
K3S_URL="https://192.168.56.110:6442"
INSTALL_K3S_EXEC="--node-ip=192.168.56.111 --flannel-iface=${PRIVATE_IFACE}"

# Install K3s agent with vars available to installer
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC" K3S_URL="$K3S_URL" K3S_TOKEN="$K3S_TOKEN" sh -s - agent

echo "K3s Agent installation complete!"
