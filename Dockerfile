# Use official Python 3.9 image as base (iotedgedev 3.3.7 requires <3.10)
FROM python:3.9-slim

# Set working directory
WORKDIR /workspace

# Update system packages and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI (includes Python 3.12)
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Create virtual environment outside workspace to avoid volume mapping conflicts
RUN python3.9 -m venv /opt/venv

# Activate venv and set PATH
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements.txt from host
COPY requirements.txt /tmp/requirements.txt

# Install requirements in virtual environment
RUN /opt/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt

# Install azure-iot extension
RUN az extension add --name azure-iot

# Note: urllib3 stays <2 via transitive deps (requests<1.27)

# Create iotedge-solution directory
RUN mkdir -p /workspace/iotedge-solution

# Set working directory to solution folder
WORKDIR /workspace/iotedge-solution

# Configure Docker socket for Docker-in-Docker
# When running container, mount the Docker socket from host:
# docker run -v /var/run/docker.sock:/var/run/docker.sock ...

# Declare volume for persistent workspace storage
VOLUME ["/workspace"]

# Note: The following commands require user input/interaction and should be run manually:
# 1. iotedgedev solution init --template c
# 2. Update .env file with IoT Hub, IoT Edge device, and container registry credentials
# 3. az login (requires interactive authentication)
# 4. docker login (requires credentials)

# Default command to keep container running with bash
CMD ["/bin/bash"]
