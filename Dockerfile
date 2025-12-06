# Use official Python 3.12 image as base
FROM python:3.12-slim

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

# Create virtual environment
RUN python3.12 -m venv /workspace/venv

# Activate venv and set PATH
ENV PATH="/workspace/venv/bin:$PATH"

# Copy requirements.txt from host
COPY requirements.txt /workspace/requirements.txt

# Install requirements in virtual environment
RUN /workspace/venv/bin/pip install --upgrade pip && \
    /workspace/venv/bin/pip install -r /workspace/requirements.txt

# Install azure-iot extension
RUN az extension add --name azure-iot

# Fix compatibility: force downgrade urllib3 to work with iotedgedev's docker dependency
RUN /workspace/venv/bin/pip install --force-reinstall "urllib3<2.0.0"

# Create iotedge-solution directory
RUN mkdir -p /workspace/iotedge-solution

# Set working directory to solution folder
WORKDIR /workspace/iotedge-solution

# Configure Docker socket for Docker-in-Docker
# When running container, mount the Docker socket from host:
# docker run -v /var/run/docker.sock:/var/run/docker.sock ...

# Note: The following commands require user input/interaction and should be run manually:
# 1. iotedgedev solution init --template c
# 2. Update .env file with IoT Hub, IoT Edge device, and container registry credentials
# 3. az login (requires interactive authentication)
# 4. docker login (requires credentials)

# Default command to keep container running with bash
CMD ["/bin/bash"]
