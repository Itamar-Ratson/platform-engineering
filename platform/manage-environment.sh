#!/bin/bash

# Environment Manager Script
# Usage: ./manage-environment.sh [create|delete] [environment-name] [app-name] [optional: image]

ACTION=$1
ENV_NAME=$2
APP_NAME=$3
IMAGE=${4:-nginx:latest}

CHART_PATH="./environment-manager"

function create_environment() {
    echo "Creating environment: $ENV_NAME-$APP_NAME"
    
    NAMESPACE="$ENV_NAME-$APP_NAME"
    
    helm upgrade --install \
        "${ENV_NAME}-${APP_NAME}" \
        "$CHART_PATH" \
        --create-namespace \
        --namespace "$NAMESPACE" \
        --set environment.name="$ENV_NAME" \
        --set app.name="$APP_NAME" \
        --set app.image="$IMAGE" \
        --wait
    
    if [ $? -eq 0 ]; then
        echo "Environment created successfully!"
        echo "Namespace: $NAMESPACE"
        kubectl get all -n "$NAMESPACE"
    else
        echo "Failed to create environment"
        exit 1
    fi
}

function delete_environment() {
    echo "Deleting environment: $ENV_NAME-$APP_NAME"
    
    NAMESPACE="$ENV_NAME-$APP_NAME"
    
    # Uninstall Helm release
    helm uninstall "${ENV_NAME}-${APP_NAME}" --namespace "$NAMESPACE"
    
    # Delete namespace (this will delete all resources in it)
    kubectl delete namespace "$NAMESPACE" --wait=false
    
    echo "Environment deletion initiated"
}

# Main logic
case $ACTION in
    create)
        if [ -z "$ENV_NAME" ] || [ -z "$APP_NAME" ]; then
            echo "Usage: ./manage-environment.sh create [environment-name] [app-name] [optional: image]"
            exit 1
        fi
        create_environment
        ;;
    delete)
        if [ -z "$ENV_NAME" ] || [ -z "$APP_NAME" ]; then
            echo "Usage: ./manage-environment.sh delete [environment-name] [app-name]"
            exit 1
        fi
        delete_environment
        ;;
    *)
        echo "Usage: ./manage-environment.sh [create|delete] [environment-name] [app-name]"
        echo "Examples:"
        echo "  ./manage-environment.sh create dev myapp nginx:latest"
        echo "  ./manage-environment.sh delete dev myapp"
        exit 1
        ;;
esac
