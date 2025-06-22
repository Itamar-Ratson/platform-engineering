#!/bin/bash

echo "Deploying Environment Manager API to Kubernetes..."

# Build the Docker image
echo "1. Building Docker image..."
docker build -f Dockerfile.k8s -t env-manager-api:latest .

# Load image to kind/minikube if using local cluster
# For EKS, push to ECR instead
if command -v kind &> /dev/null; then
    echo "Loading image to kind cluster..."
    kind load docker-image env-manager-api:latest
elif command -v minikube &> /dev/null; then
    echo "Loading image to minikube..."
    minikube image load env-manager-api:latest
else
    echo "For EKS, push image to ECR:"
    echo "  aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin <your-ecr-uri>"
    echo "  docker tag env-manager-api:latest <your-ecr-uri>/env-manager-api:latest"
    echo "  docker push <your-ecr-uri>/env-manager-api:latest"
    echo "  Then update image in deployment.yaml"
fi

# Apply Kubernetes manifests
echo "2. Applying Kubernetes manifests..."
kubectl apply -f k8s-manifests/deployment.yaml

# Wait for deployment
echo "3. Waiting for deployment to be ready..."
kubectl rollout status deployment/env-manager-api -n default

# Get service endpoint
echo "4. Getting service endpoint..."
kubectl get service env-manager-api -n default

echo "Deployment complete!"
echo ""
echo "Test the API:"
echo "  # Get LoadBalancer IP/DNS"
echo "  kubectl get service env-manager-api -n default"
echo "  "
echo "  # Port-forward for local testing"
echo "  kubectl port-forward service/env-manager-api 8080:80"
echo "  curl http://localhost:8080/health"
