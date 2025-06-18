FROM python:3.9-slim

WORKDIR /app

# Install kubectl and helm
RUN apt-get update && apt-get install -y curl unzip && \
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/ && \
    # Install helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws && \
    apt-get clean

COPY python-app/requirements.txt .
RUN pip install -r requirements.txt

COPY python-app/app.py .
COPY platform/environment-manager ./environment-manager

EXPOSE 5000

CMD ["python", "app.py"]
