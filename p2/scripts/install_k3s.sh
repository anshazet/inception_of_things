#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Set the hostname based on the login
sudo hostnamectl set-hostname tde-los-S

# Install K3s with Traefik Ingress Controller enabled (default)
# We're not disabling traefik because we need the ingress controller
export INSTALL_K3S_EXEC="--bind-address=192.168.56.110 --node-ip=192.168.56.110"
curl -sfL https://get.k3s.io | sh -

# Make kubectl available for non-root user
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
chmod 600 $HOME/.kube/config

# Install required packages
apt-get install -y curl

# Update hosts file to include the application domains
echo "127.0.0.1 app1.com app2.com" >> /etc/hosts

echo "K3s installation complete on tde-los-S!"