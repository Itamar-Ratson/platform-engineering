# ECR Management with ACK

This setup uses AWS Controllers for Kubernetes (ACK) to manage ECR repositories as Kubernetes resources.

## How It Works

1. **ACK ECR Controller**: Runs in your cluster and watches for Repository resources
2. **IRSA**: Controller uses IAM role to create/manage ECR repositories
3. **Repository CRD**: Define ECR repositories using Kubernetes manifests

## Files

- `ecr_ack_controller_install.sh` - Installs ACK ECR controller
- `ecr_irsa.sh` - Sets up IAM roles for service accounts
- `ecr-repository.yaml` - Kubernetes manifest for ECR repository
- `setup-ecr-ack.sh` - Complete setup automation

## Managing ECR Repositories

```bash
# Create repository
kubectl apply -f ecr-repository.yaml

# Check repository status
kubectl get repository env-manager-api -n default
kubectl describe repository env-manager-api -n default

# Get repository URI
kubectl get repository env-manager-api -n default -o jsonpath='{.status.repositoryURI}'

# Delete repository (WARNING: deletes all images)
kubectl delete repository env-manager-api -n default
```

## Benefits

- **GitOps Compatible**: ECR repositories defined as code
- **Kubernetes Native**: Manage AWS resources with kubectl
- **No AWS CLI Required**: After initial setup, everything is managed via Kubernetes
- **Consistent with DynamoDB**: Same ACK pattern as your DynamoDB setup

## Troubleshooting

```bash
# Check ACK controller logs
kubectl logs -n ack-system deployment/ack-ecr-controller-ecr-chart

# Check repository sync status
kubectl get repository env-manager-api -n default -o jsonpath='{.status.conditions}'
```
