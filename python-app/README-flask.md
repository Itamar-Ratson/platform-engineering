# Environment Manager Flask API

Simple Flask API for managing Kubernetes environments.

## Setup

```bash
# Install Flask
pip install -r requirements.txt

# Run the app
python app.py
```

## API Endpoints

### Create Environment
```bash
curl -X POST http://localhost:5000/create \
  -H "Content-Type: application/json" \
  -d '{
    "environment": "dev",
    "app": "webapp",
    "image": "nginx:latest"
  }'
```

### Check Status
```bash
curl http://localhost:5000/status/dev/webapp
```

### Delete Environment
```bash
curl -X DELETE http://localhost:5000/delete \
  -H "Content-Type: application/json" \
  -d '{
    "environment": "dev",
    "app": "webapp"
  }'
```

### Health Check
```bash
curl http://localhost:5000/health
```

## Requirements

- Python 3
- kubectl configured
- Helm 3 installed
- Access to EKS cluster
- Environment Manager Helm chart in `./environment-manager/`

## Response Format

All endpoints return JSON responses with relevant information about the operation.
