# IoT Edge Docker Development Environment

## Quick Start

### Build the Docker image
```powershell
docker build -t iotedge-dev:latest .
```

### Run the container with Docker-in-Docker support
```powershell
docker run -it -v /var/run/docker.sock:/var/run/docker.sock iotedge-dev:latest
```

### Inside the container - Initialize IoT Edge solution
```bash
iotedgedev solution init --template c
```

### Login to container registry
```bash
echo <container registry password> | docker login -u <container registry username> --password-stdin <container registry server>
```

### Build the module image
```bash
iotedgedev build --platform arm64v8
```

### Push the module image
```bash
iotedgedev push
```
