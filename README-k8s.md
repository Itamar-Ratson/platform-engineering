# Running Environment Manager API in Kubernetes

Deploy the Flask API inside your EKS cluster for in-cluster environment management.

## Architecture

- Flask API runs as a Deployment in the cluster
- Uses ServiceAccount with RBAC for permissions
- ECR repository provisioned via ACK (AWS Controllers for Kubernetes)
- Exposed via ClusterIP Service (use LoadBalancer or Ingress for external access)
- No AWS credentials needed for API (uses in-cluster auth)

## Prerequisites

- EKS cluster with OIDC provider
- ACK system namespace (created if not exists)
- AWS CLI configured locally for initial setup

## Setup ECR with ACK

```bash
# 1. Run the complete ACK ECR setup
chmod +x setup-ecr-ack.sh
./setup-ecr-ack.sh

# This will:
# - Install ACK ECR controller
# - Setup IRSA for the controller
# - Create ECR repository via Kubernetes manifest
```

## Deploy the API

```bash
# 1. Push image to ACK-managed ECR
./push-to-ecr.sh

# 2. Update image in deployment.yaml with the ECR URI shown by the script

# 3. Deploy to cluster
kubectl apply -f k8s-manifests/deployment.yaml

# 4. Check deployment
kubectl get pods -l app=env-manager-api
kubectl get service env-manager-api
```

## Testing

```bash
# Port-forward for testing
kubectl port-forward service/env-manager-api 8080:80

# Test endpoints
curl http://localhost:8080/health

# Create environment
curl -X POST http://localhost:8080/create \
  -H "Content-Type: application/json" \
  -d '{"environment": "dev", "app": "testapp", "image": "nginx:alpine"}'
```

## Production Access

For EKS with LoadBalancer:
```bash
# Get LoadBalancer URL
kubectl get service env-manager-api -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## External Access Options

1. **Port Forward** (Development):
   ```bash
   kubectl port-forward service/env-manager-api 8080:80
   ```

2. **LoadBalancer** (Simple):
   - Change service type to `LoadBalancer` in deployment.yaml
   - AWS will provision an ELB

3. **Ingress** (Production):
   - Keep service as `ClusterIP`
   - Use ALB Ingress Controller or NGINX Ingress

## Files

- `Dockerfile.k8s` - Simplified Dockerfile without AWS CLI
- `k8s-manifests/deployment.yaml` - All K8s resources (SA, RBAC, Deployment, Service)
- `app.py` - Modified to detect in-cluster execution
- **ECR with ACK**:
  - `setup-ecr-ack.sh` - Complete ACK setup
  - `ecr-repository.yaml` - ECR repository definition
  - `ecr_ack_controller_install.sh` - ACK controller installation
  - `ecr_irsa.sh` - IRSA setup for ACK
- `push-to-ecr.sh` - Push images to ECR (works with ACK-managed repos)

## How It Works

1. Pod uses ServiceAccount with ClusterRole permissions
2. kubectl/helm commands use in-cluster authentication
3. Can create/delete namespaces and deploy apps
4. No external credentials needed
