#!/bin/bash

# Complete setup script for ECR with ACK

echo "Setting up ECR with ACK..."

# Step 1: Install ACK ECR Controller
echo "Step 1: Installing ACK ECR Controller..."
chmod +x ecr_ack_controller_install.sh
./ecr_ack_controller_install.sh

# Wait for controller to be ready
echo "Waiting for ECR controller to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/ack-ecr-controller-ecr-chart -n ack-system

# Step 2: Setup IRSA
echo "Step 2: Setting up IRSA for ECR controller..."
chmod +x ecr_irsa.sh
./ecr_irsa.sh

# Step 3: Create ECR repository
echo "Step 3: Creating ECR repository via ACK..."
kubectl apply -f ecr-repository.yaml

# Wait for repository to be created
echo "Waiting for repository to be created..."
kubectl wait --for=condition=ACK.ResourceSynced repository/env-manager-api -n default --timeout=120s

# Show repository details
echo "ECR Repository created!"
kubectl get repository env-manager-api -n default -o yaml

echo ""
echo "Setup complete! You can now push images using:"
echo "  ./push-to-ecr.sh"
