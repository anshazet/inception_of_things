# Makefile for Inception of Things Part 3

# Colors for output
GREEN = \033[0;32m
RED = \033[0;31m
RESET = \033[0m

# Default target
all: setup deploy

# Setup the environment, create cluster, install k3d, etc.
setup:
	@echo "${GREEN}Setting up K3d and creating cluster...${RESET}"
	@cd p3/scripts && ./setup.sh

# Setup the repository with manifests (only needed for initial setup)
repo:
	@echo "${GREEN}Setting up GitHub repository...${RESET}"
	@cd p3/scripts && ./setup_repo.sh
	@echo "${GREEN}Note: This is only needed for initial repository setup.${RESET}"
	@echo "${GREEN}If your repository is already configured, you don't need to run this again.${RESET}"

# Deploy Argo CD and applications
deploy:
	@echo "${GREEN}Deploying Argo CD and applications...${RESET}"
	@cd p3/scripts && ./deploy.sh

# Full install: setup and deploy (without repo setup)
install: setup deploy
	@echo "${GREEN}Full installation completed!${RESET}"

# Full install with repo setup (rarely needed)
install-with-repo: setup repo deploy
	@echo "${GREEN}Full installation with repository setup completed!${RESET}"

# Test the application
test:
	@echo "${GREEN}Testing the application...${RESET}"
	@curl http://localhost:8888 || echo "${RED}Failed to connect to application${RESET}"

# Kill port forwarding processes
kill-port-forward:
	@echo "${GREEN}Killing port-forward processes...${RESET}"
	@-pkill -f "port-forward" || echo "${RED}No port-forward processes found${RESET}"

# Delete Argo CD application
delete-app:
	@echo "${GREEN}Deleting Argo CD application...${RESET}"
	@-kubectl delete application wil-playground -n argocd || echo "${RED}Failed to delete application${RESET}"

# Delete namespaces
delete-namespaces:
	@echo "${GREEN}Deleting namespaces...${RESET}"
	@-kubectl delete namespace argocd || echo "${RED}Failed to delete argocd namespace${RESET}"
	@-kubectl delete namespace dev || echo "${RED}Failed to delete dev namespace${RESET}"

# Stop k3d cluster without deleting it
stop:
	@echo "${GREEN}Stopping k3d cluster...${RESET}"
	@-k3d cluster stop iot-cluster || echo "${RED}Failed to stop k3d cluster${RESET}"

# Start k3d cluster that was previously stopped
start:
	@echo "${GREEN}Starting k3d cluster...${RESET}"
	@-k3d cluster start iot-cluster || echo "${RED}Failed to start k3d cluster${RESET}"
	@echo "${GREEN}You may need to run 'make deploy' again to set up port-forwarding${RESET}"

# Delete k3d cluster
delete-cluster:
	@echo "${GREEN}Deleting k3d cluster...${RESET}"
	@-k3d cluster delete iot-cluster || echo "${RED}Failed to delete k3d cluster${RESET}"

# Clean up everything
clean: kill-port-forward delete-app delete-namespaces delete-cluster
	@echo "${GREEN}Environment cleaned up successfully${RESET}"

# Re-deploy Argo CD application (useful for updates)
redeploy: kill-port-forward
	@echo "${GREEN}Redeploying Argo CD and applications...${RESET}"
	@cd p3/scripts && ./deploy.sh

# Update application from v1 to v2 or vice versa
toggle-version:
	@echo "${GREEN}Toggling application version...${RESET}"
	@echo "${GREEN}Removing existing repository folder for clean operation...${RESET}"
	@rm -rf /tmp/tde-los-update
	@echo "${GREEN}Cloning repository using SSH...${RESET}"
	@mkdir -p /tmp/tde-los-update
	@git clone git@github.com:anshazet/tde-los-.git /tmp/tde-los-update || \
		(echo "${RED}SSH clone failed, trying HTTPS...${RESET}" && \
		git clone https://github.com/anshazet/tde-los-.git /tmp/tde-los-update)
	@cd /tmp/tde-los-update && \
	if grep -q "v1" manifests/deployment.yaml; then \
		echo "${GREEN}Changing from v1 to v2...${RESET}"; \
		sed -i '' 's/wil42\/playground:v1/wil42\/playground:v2/g' manifests/deployment.yaml; \
	else \
		echo "${GREEN}Changing from v2 to v1...${RESET}"; \
		sed -i '' 's/wil42\/playground:v2/wil42\/playground:v1/g' manifests/deployment.yaml; \
	fi
	@cd /tmp/tde-los-update && \
	git add manifests/deployment.yaml && \
	git config --local user.email "anshazet@github.com" && \
	git config --local user.name "iot-script" && \
	git commit -m "Toggle application version" && \
	git push || \
	(echo "${RED}Push failed. If using HTTPS, you need a personal access token.${RESET}" && \
	echo "${RED}To use SSH authentication instead, setup your SSH key in GitHub.${RESET}" && \
	echo "${GREEN}Your changes are committed locally in /tmp/tde-los-update${RESET}" && \
	echo "${GREEN}You can push them manually later with:${RESET}" && \
	echo "cd /tmp/tde-los-update && git push" && exit 1)
	@echo "${GREEN}Version toggled successfully. ArgoCD will sync automatically.${RESET}"
	@rm -rf /tmp/tde-los-update

# Version 1: Set application to version 1
set-v1:
	@echo "${GREEN}Setting application to v1...${RESET}"
	@echo "${GREEN}Removing existing repository folder for clean operation...${RESET}"
	@rm -rf /tmp/tde-los-update
	@echo "${GREEN}Cloning repository using SSH...${RESET}"
	@mkdir -p /tmp/tde-los-update
	@git clone git@github.com:anshazet/tde-los-.git /tmp/tde-los-update || \
		(echo "${RED}SSH clone failed, trying HTTPS...${RESET}" && \
		git clone https://github.com/anshazet/tde-los-.git /tmp/tde-los-update)
	@cd /tmp/tde-los-update && \
	sed -i '' 's/wil42\/playground:v[12]/wil42\/playground:v1/g' manifests/deployment.yaml && \
	git add manifests/deployment.yaml && \
	git config --local user.email "anshazet@github.com" && \
	git config --local user.name "iot-script" && \
	git commit -m "Set application to v1" && \
	git push || \
	(echo "${RED}Push failed. If using HTTPS, you need a personal access token.${RESET}" && \
	echo "${RED}To use SSH authentication instead, setup your SSH key in GitHub.${RESET}" && \
	echo "${GREEN}Your changes are committed locally in /tmp/tde-los-update${RESET}" && \
	echo "${GREEN}You can push them manually later with:${RESET}" && \
	echo "cd /tmp/tde-los-update && git push" && exit 1)
	@echo "${GREEN}Application set to v1. ArgoCD will sync automatically.${RESET}"
	@rm -rf /tmp/tde-los-update

# Version 2: Set application to version 2
set-v2:
	@echo "${GREEN}Setting application to v2...${RESET}"
	@echo "${GREEN}Removing existing repository folder for clean operation...${RESET}"
	@rm -rf /tmp/tde-los-update
	@echo "${GREEN}Cloning repository using SSH...${RESET}"
	@mkdir -p /tmp/tde-los-update
	@git clone git@github.com:anshazet/tde-los-.git /tmp/tde-los-update || \
		(echo "${RED}SSH clone failed, trying HTTPS...${RESET}" && \
		git clone https://github.com/anshazet/tde-los-.git /tmp/tde-los-update)
	@cd /tmp/tde-los-update && \
	sed -i '' 's/wil42\/playground:v[12]/wil42\/playground:v2/g' manifests/deployment.yaml && \
	git add manifests/deployment.yaml && \
	git config --local user.email "anshazet@github.com" && \
	git config --local user.name "iot-script" && \
	git commit -m "Set application to v2" && \
	git push || \
	(echo "${RED}Push failed. If using HTTPS, you need a personal access token.${RESET}" && \
	echo "${RED}To use SSH authentication instead, setup your SSH key in GitHub.${RESET}" && \
	echo "${GREEN}Your changes are committed locally in /tmp/tde-los-update${RESET}" && \
	echo "${GREEN}You can push them manually later with:${RESET}" && \
	echo "cd /tmp/tde-los-update && git push" && exit 1)
	@echo "${GREEN}Application set to v2. ArgoCD will sync automatically.${RESET}"
	@rm -rf /tmp/tde-los-update

# Clean up temporary repository
clean-repo:
	@echo "${GREEN}Cleaning up temporary repository...${RESET}"
	@rm -rf /tmp/tde-los-update
	@echo "${GREEN}Temporary repository removed.${RESET}"

# Show status of application
status:
	@echo "${GREEN}Checking cluster status...${RESET}"
	@echo "${GREEN}K3d cluster:${RESET}"
	@k3d cluster list
	@echo
	@echo "${GREEN}Argo CD applications:${RESET}"
	@kubectl get applications -n argocd
	@echo
	@echo "${GREEN}Pods in dev namespace:${RESET}"
	@kubectl get pods -n dev
	@echo
	@echo "${GREEN}Service in dev namespace:${RESET}"
	@kubectl get svc -n dev
	@echo
	@echo "${GREEN}Port forwarding processes:${RESET}"
	@ps aux | grep "port-forward" | grep -v grep || echo "No port-forwarding processes"
	@echo
	@echo "${GREEN}Application version:${RESET}"
	@curl -s http://localhost:8888 || echo "${RED}Failed to connect to application${RESET}"

# Show help information
help:
	@echo "${GREEN}Available commands:${RESET}"
	@echo "  make setup          - Setup K3d cluster and install prerequisites"
	@echo "  make deploy         - Deploy Argo CD and applications"
	@echo "  make install        - Full installation (setup + deploy)"
	@echo "  make test           - Test the application"
	@echo "  make kill-port-forward - Kill port forwarding processes"
	@echo "  make delete-app     - Delete Argo CD application"
	@echo "  make delete-namespaces - Delete argocd and dev namespaces"
	@echo "  make stop           - Stop k3d cluster without deleting it"
	@echo "  make start          - Start k3d cluster that was previously stopped"
	@echo "  make delete-cluster - Delete k3d cluster"
	@echo "  make clean          - Clean up everything"
	@echo "  make redeploy       - Re-deploy Argo CD application"
	@echo "  make toggle-version - Toggle application between v1 and v2"
	@echo "  make set-v1         - Set application to version 1"
	@echo "  make set-v2         - Set application to version 2"
	@echo "  make clean-repo     - Clean up temporary repository folder"
	@echo "  make status         - Show status of all components"
	@echo "  make repo           - Setup GitHub repository (only for initial setup)"
	@echo "  make help           - Show this help message"

.PHONY: all setup repo deploy install install-with-repo test kill-port-forward delete-app delete-namespaces stop start delete-cluster clean redeploy toggle-version set-v1 set-v2 clean-repo status help
