#!/bin/bash
set -e

# Mise à jour du système et installation d'outils nécessaires
apt-get update -y
apt-get upgrade -y

# Installation de K3s en mode serveur
curl -sfL https://get.k3s.io | sh -

# Attendre que K3s soit bien démarré
sleep 10

# Définir le fichier de configuration kubectl
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Lier kubectl dans /usr/bin pour facilité d'utilisation
ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

# (Optionnel) Installation de Helm pour faciliter le déploiement d'applications
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Copier les applications depuis le dossier partagé (synced folder) vers un emplacement dédié
mkdir -p /home/vagrant/app
cp -R /vagrant/confs/app/* /home/vagrant/app/
chown -R vagrant:vagrant /home/vagrant/app

# Appliquer les manifestes Kubernetes (depuis le dossier k8s)
for manifest in /vagrant/confs/*.yaml; do
  echo "Appliquer $manifest"
  kubectl apply -f "$manifest"
done

echo "Installation du serveur K3s et déploiement des applications terminés."


