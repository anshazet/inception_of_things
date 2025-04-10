#!/bin/bash

# Update system first
apt-get update
apt-get upgrade -y

# Set up K3s server
export INSTALL_K3S_EXEC="--bind-address=192.168.56.110 --node-ip=192.168.56.110 --flannel-iface=eth1"

# Install K3s without traefik (we'll use our own ingress later)
curl -sfL https://get.k3s.io | sh -s - --disable=traefik

# Make the kubeconfig file readable for vagrant user
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
chmod 600 /home/vagrant/.kube/config

# Create a token file for agents to join
cat /var/lib/rancher/k3s/server/node-token > /vagrant/confs/node-token

# Export the token
echo "export K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)" >> /home/vagrant/.bashrc
echo "export K3S_URL=https://192.168.56.110:6443" >> /home/vagrant/.bashrc

# Wait for k3s to be ready
sleep 5
echo "K3s Server installation complete!" 