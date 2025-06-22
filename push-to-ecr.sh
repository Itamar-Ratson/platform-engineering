#!/bin/bash

# ECR push script for Environment Manager API using ACK-managed repository

REGION="eu-north-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
IMAGE_NAME="env-manager-api"

echo "Checking if ECR repository exists via ACK..."
if ! kubectl get repository env-manager-api -n default &>/dev/null; then
    echo "ECR repository not found. Please create it first:"
    echo "  kubectl apply -f ecr-repository.yaml"
    exit 1
fi

echo "Waiting for repository to be ready..."
kubectl wait --for=condition=ACK.ResourceSynced repository/env-manager-api -n default --timeout=60s

echo "Getting repository URI..."
REPO_URI=$(kubectl get repository env-manager-api -n default -o jsonpath='{.status.repositoryURI}')

if [ -z "$REPO_URI" ]; then
    echo "Failed to get repository URI. Repository may not be ready yet."
    exit 1
fi

echo "Repository URI: $REPO_URI"

echo "Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI

echo "Building image..."
docker build -f Dockerfile.k8s -t $IMAGE_NAME:latest .

echo "Tagging image..."
docker tag $IMAGE_NAME:latest $REPO_URI:latest

echo "Pushing to ECR..."
docker push $REPO_URI:latest

echo "Done! Image pushed to: $REPO_URI:latest"
echo ""
echo "Update the image in k8s-manifests/deployment.yaml:"
echo "  image: $REPO_URI:latest"
