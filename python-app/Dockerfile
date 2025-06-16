FROM python:3.9-slim

WORKDIR /app

# Install kubectl and helm
RUN apt-get update && apt-get install -y curl && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/ && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    apt-get clean

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .
COPY environment-manager ./environment-manager

EXPOSE 5000

CMD ["python", "app.py"]
