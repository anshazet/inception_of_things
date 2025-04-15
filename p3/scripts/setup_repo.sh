#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# GitHub repository URL
REPO_URL="git@github.com:anshazet/tde-los-.git"
REPO_HTTPS_URL="https://github.com/anshazet/tde-los-.git"

echo -e "${GREEN}Setting up GitHub repository...${NC}"

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
echo -e "${GREEN}Created temporary directory: $TEMP_DIR${NC}"

# Clone the repository if it exists or initialize a new one
if git ls-remote $REPO_HTTPS_URL &> /dev/null; then
  echo -e "${GREEN}Repository exists. Cloning...${NC}"
  git clone $REPO_URL $TEMP_DIR || {
    echo -e "${RED}Failed to clone repository. Trying with HTTPS...${NC}"
    git clone $REPO_HTTPS_URL $TEMP_DIR || {
      echo -e "${RED}Failed to clone repository with HTTPS as well. Please check your credentials.${NC}"
      exit 1
    }
  }
else
  echo -e "${RED}Repository does not exist or is not accessible. Please create it on GitHub.${NC}"
  exit 1
fi

# Create the manifests directory
mkdir -p $TEMP_DIR/manifests

# Create the deployment.yaml file
cat > $TEMP_DIR/manifests/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: playground
  namespace: dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: playground
  template:
    metadata:
      labels:
        app: playground
    spec:
      containers:
      - name: playground
        image: wil42/playground:v1
        ports:
        - containerPort: 8888
---
apiVersion: v1
kind: Service
metadata:
  name: playground
  namespace: dev
spec:
  selector:
    app: playground
  ports:
  - port: 8888
    targetPort: 8888
    nodePort: 30888
  type: NodePort
EOF

# Commit and push the changes
cd $TEMP_DIR
git add manifests
git commit -m "Add deployment manifest for wil42/playground:v1"
git push

echo -e "${GREEN}Repository setup complete!${NC}"
echo -e "${GREEN}The manifests directory with deployment.yaml has been added to your repository.${NC}"
echo -e "${GREEN}You can find it at: $REPO_HTTPS_URL${NC}"
echo -e "${GREEN}Temporary directory: $TEMP_DIR${NC}"
