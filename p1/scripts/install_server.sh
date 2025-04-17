#!/bin/bash

# Update system
apt-get update -y
apt install -y net-tools
apt-get upgrade -y

# Détecte l'interface réseau privée
PRIVATE_IFACE=$(ip -o -4 addr show | awk '/192\.168\.56\./ {print $2; exit}')
echo "Detected private network interface: $PRIVATE_IFACE"

# Set up K3s server
export INSTALL_K3S_EXEC="--bind-address=192.168.56.110 --node-ip=192.168.56.110 --flannel-iface=${PRIVATE_IFACE}"
# export INSTALL_K3S_EXEC="--bind-address=192.168.56.110 --node-ip=192.168.56.110 --flannel-iface=eth1"

# Install K3s without traefik
curl -sfL https://get.k3s.io | sh -s - --disable=traefik

# Make the kubeconfig file readable for vagrant user
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
chmod 600 /home/vagrant/.kube/config

# Ensure directory exists for sharing the token
mkdir -p /vagrant/confs

# Create a token file for agents to join
cat /var/lib/rancher/k3s/server/node-token > /vagrant/confs/node-token
chmod 644 /vagrant/confs/node-token

# Export the token
echo "export K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)" >> /home/vagrant/.bashrc
echo "export K3S_URL=https://192.168.56.110:6443" >> /home/vagrant/.bashrc

# Wait for k3s to be ready
sleep 10
echo "K3s Server installation complete!"
