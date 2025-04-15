#!/bin/bash
# Deploy all applications
kubectl apply -f ../confs/app1.yaml
kubectl apply -f ../confs/app2.yaml
kubectl apply -f ../confs/app3.yaml

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available deployment/app-one --timeout=120s
kubectl wait --for=condition=available deployment/app-two --timeout=120s
kubectl wait --for=condition=available deployment/app-three --timeout=120s

# Deploy the ingress configuration
kubectl apply -f ../confs/ingress.yaml

# Show deployment status
echo "Deployment status:"
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get ingress

echo "To test the applications, add the following to your hosts file:"
echo "192.168.56.110 app1.com app2.com"
echo "Then access http://app1.com, http://app2.com, or http://192.168.56.110 (app3)"
