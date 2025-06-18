#!/usr/bin/env python3
from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

CHART_PATH = "./environment-manager"

def run_command(cmd):
    """Execute shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout, result.stderr, result.returncode
    except Exception as e:
        return "", str(e), 1

@app.route('/create', methods=['POST'])
def create_environment():
    data = request.json
    env_name = data.get('environment')
    app_name = data.get('app')
    image = data.get('image', 'nginx:latest')
    
    if not env_name or not app_name:
        return jsonify({'error': 'Missing environment or app name'}), 400
    
    namespace = f"{env_name}-{app_name}"
    release_name = f"{env_name}-{app_name}"
    
    # Create environment using helm
    cmd = f"""helm upgrade --install {release_name} {CHART_PATH} \
        --create-namespace \
        --namespace {namespace} \
        --set environment.name={env_name} \
        --set app.name={app_name} \
        --set app.image={image} \
        --wait"""
    
    stdout, stderr, code = run_command(cmd)
    
    if code == 0:
        # Get pod status
        status_cmd = f"kubectl get pods -n {namespace} -o wide"
        status_out, _, _ = run_command(status_cmd)
        
        return jsonify({
            'status': 'created',
            'namespace': namespace,
            'output': stdout,
            'pods': status_out
        }), 200
    else:
        return jsonify({'error': stderr}), 500

@app.route('/delete', methods=['DELETE'])
def delete_environment():
    data = request.json
    env_name = data.get('environment')
    app_name = data.get('app')
    
    if not env_name or not app_name:
        return jsonify({'error': 'Missing environment or app name'}), 400
    
    namespace = f"{env_name}-{app_name}"
    release_name = f"{env_name}-{app_name}"
    
    # Delete helm release
    helm_cmd = f"helm uninstall {release_name} --namespace {namespace}"
    helm_out, helm_err, helm_code = run_command(helm_cmd)
    
    # Delete namespace
    ns_cmd = f"kubectl delete namespace {namespace} --wait=false"
    ns_out, ns_err, ns_code = run_command(ns_cmd)
    
    return jsonify({
        'status': 'deleted',
        'namespace': namespace,
        'helm_output': helm_out,
        'namespace_output': ns_out
    }), 200

@app.route('/status/<environment>/<app>', methods=['GET'])
def check_status(environment, app):
    namespace = f"{environment}-{app}"
    
    # Check if namespace exists
    check_cmd = f"kubectl get namespace {namespace}"
    _, _, code = run_command(check_cmd)
    
    if code != 0:
        return jsonify({'error': f'Environment {namespace} does not exist'}), 404
    
    # Get pods
    pods_cmd = f"kubectl get pods -n {namespace} -o wide"
    pods_out, _, _ = run_command(pods_cmd)
    
    # Get pod images
    images_cmd = f"kubectl get pods -n {namespace} -o jsonpath='{{range .items[*]}}{{.metadata.name}}{{\"\\t\"}}{{range .spec.containers[*]}}{{.image}}{{\"\\n\"}}{{end}}{{end}}'"
    images_out, _, _ = run_command(images_cmd)
    
    # Get all resources
    all_cmd = f"kubectl get all -n {namespace}"
    all_out, _, _ = run_command(all_cmd)
    
    # Get events
    events_cmd = f"kubectl get events -n {namespace} --sort-by='.lastTimestamp' | tail -5"
    events_out, _, _ = run_command(events_cmd)
    
    return jsonify({
        'namespace': namespace,
        'pods': pods_out,
        'images': images_out,
        'resources': all_out,
        'events': events_out
    }), 200

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
