#!/bin/bash

# Test script for Environment Manager Flask API

API_URL="http://localhost:5000"

echo "1. Creating dev environment..."
curl -X POST $API_URL/create \
  -H "Content-Type: application/json" \
  -d '{
    "environment": "dev",
    "app": "testapp",
    "image": "nginx:alpine"
  }' | jq .

echo -e "\n2. Checking status..."
sleep 5
curl $API_URL/status/dev/testapp | jq .

echo -e "\n3. Deleting environment..."
curl -X DELETE $API_URL/delete \
  -H "Content-Type: application/json" \
  -d '{
    "environment": "dev",
    "app": "testapp"
  }' | jq .

echo -e "\nTest complete!"
