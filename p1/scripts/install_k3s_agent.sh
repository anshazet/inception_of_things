#!/bin/bash

# Update system first
apt-get update
apt-get upgrade -y

# Wait for the server token to be available
while [ ! -f /vagrant/confs/node-token ]; do
  echo "Waiting for server node-token..."
  sleep 5
done

# Get the token
export K3S_TOKEN=$(cat /vagrant/confs/node-token)
export K3S_URL=https://192.168.56.110:6443

# Set up K3s agent with proper network interface
export INSTALL_K3S_EXEC="--node-ip=192.168.56.111 --flannel-iface=eth1"

# Install K3s agent
curl -sfL https://get.k3s.io | sh -s - agent

# Export variables for easier access
echo "export K3S_TOKEN=${K3S_TOKEN}" >> /home/vagrant/.bashrc
echo "export K3S_URL=${K3S_URL}" >> /home/vagrant/.bashrc

# Wait for k3s to be ready
sleep 5
echo "K3s Agent installation complete!" 