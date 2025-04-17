#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting setup for K3d and Argo CD...${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker Desktop first.${NC}"
    exit 1
else
    echo -e "${GREEN}Docker is already installed.${NC}"
fi

# Install kubectl if not installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${GREEN}Installing kubectl...${NC}"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    echo -e "${GREEN}kubectl installed successfully.${NC}"
else
    echo -e "${GREEN}kubectl is already installed.${NC}"
fi

# Install K3d if not installed
if ! command -v k3d &> /dev/null; then
    echo -e "${GREEN}Installing K3d...${NC}"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    echo -e "${GREEN}K3d installed successfully.${NC}"
else
    echo -e "${GREEN}K3d is already installed.${NC}"
fi

# Create K3d cluster
echo -e "${GREEN}Creating K3d cluster...${NC}"
k3d cluster create iot-cluster --api-port 6442 --servers 1 --agents 1 -p "8888:30888@loadbalancer"

# Install Argo CD CLI
if ! command -v argocd &> /dev/null; then
    echo -e "${GREEN}Installing Argo CD CLI...${NC}"
    brew install argocd
    echo -e "${GREEN}Argo CD CLI installed successfully.${NC}"
else
    echo -e "${GREEN}Argo CD CLI is already installed.${NC}"
fi

echo -e "${GREEN}Setup completed successfully!${NC}"
