#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Go one level up to get to the p3 directory
P3_DIR="$(dirname "$SCRIPT_DIR")"
CONFS_DIR="$P3_DIR/confs"

echo -e "${GREEN}Deploying Kubernetes resources from $CONFS_DIR...${NC}"

# Create namespaces directly with kubectl
echo -e "${GREEN}Creating namespaces...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

# Verify namespaces were created
echo -e "${GREEN}Verifying namespaces...${NC}"
kubectl get namespaces | grep -E 'argocd|dev'

# Install Argo CD
echo -e "${GREEN}Installing Argo CD...${NC}"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
echo -e "${GREEN}Waiting for Argo CD to be ready...${NC}"
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s || {
  echo -e "${RED}Timeout waiting for argocd-server to become ready.${NC}"
  kubectl get all -n argocd
  exit 1
}

# Wait for argocd-initial-admin-secret to be created
echo -e "${GREEN}Waiting for Argo CD admin secret to be available...${NC}"
for i in {1..10}; do
  ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)
  if [ -n "$ARGOCD_PASSWORD" ]; then
    echo -e "${GREEN}Argo CD admin password retrieved.${NC}"
    break
  fi
  echo -e "${RED}Secret not ready yet. Retrying in 5 seconds... ($i/10)${NC}"
  sleep 5
done

if [ -z "$ARGOCD_PASSWORD" ]; then
  echo -e "${RED}Failed to get Argo CD password. Is the secret created?${NC}"
  echo -e "${GREEN}Checking secrets in argocd namespace:${NC}"
  kubectl get secrets -n argocd
  echo -e "${GREEN}Using default password 'admin' for now...${NC}"
  ARGOCD_PASSWORD="admin"
else
  echo -e "${GREEN}Argo CD admin password: ${ARGOCD_PASSWORD}${NC}"
fi

# Port forward Argo CD server
echo -e "${GREEN}Setting up port forwarding for Argo CD server...${NC}"
echo -e "${GREEN}Argo CD will be available at https://localhost:8080${NC}"
pkill -f "kubectl port-forward svc/argocd-server" || true
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
ARGOCD_PID=$!
sleep 5

# Login to Argo CD
echo -e "${GREEN}Logging in to Argo CD...${NC}"
for i in {1..5}; do
  argocd login localhost:8080 --username admin --password "$ARGOCD_PASSWORD" --insecure && break || {
    echo -e "${RED}Attempt $i failed. Retrying in 5 seconds...${NC}"
    sleep 5
  }
done

# Check if argocd-application.yaml exists
if [ -f "$CONFS_DIR/argocd-application.yaml" ]; then
  echo -e "${GREEN}Creating Argo CD application...${NC}"
  kubectl apply -f "$CONFS_DIR/argocd-application.yaml"
else
  echo -e "${RED}$CONFS_DIR/argocd-application.yaml doesn't exist! Creating it now...${NC}"
  cat > "$CONFS_DIR/argocd-application.yaml" << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: playground
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/NineSuper/tde-los-.git
    targetRevision: HEAD
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
  kubectl apply -f "$CONFS_DIR/argocd-application.yaml"
fi

echo -e "${GREEN}Deployment completed! You can access:${NC}"
echo -e "${GREEN}Argo CD UI: https://localhost:8080 (admin/${ARGOCD_PASSWORD})${NC}"
echo -e "${GREEN}Application: http://localhost:8888${NC}"

echo -e "${GREEN}Remember:${NC}"
echo -e "${GREEN}1. Make sure your GitHub repo has a manifests/deployment.yaml file${NC}"
echo -e "${GREEN}2. To update the application version, edit the deployment.yaml in your GitHub repository and change 'wil42/playground:v1' to 'wil42/playground:v2'${NC}"
echo -e "${GREEN}3. The port-forward is running in the background. To stop it: kill $ARGOCD_PID${NC}"
