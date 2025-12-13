# IoT Edge Dev Container Usage

This workspace uses a Docker container to run `iotedgedev` commands with the project files mapped from the host.

The docker container of Microsoft is used. For more information check [Microsoft Learn: Tutorial – Develop IoT Edge modules using Visual Studio Code](https://learn.microsoft.com/en-us/azure/iot-edge/tutorial-develop-for-linux?view=iotedge-1.4&tabs=c&pivots=iotedge-dev-cli)

### Build and start the container
```powershell
docker-compose up -d --build
```

**Note:** The `docker-compose.yml` file configures:
- Docker-in-Docker support via Docker socket mounting
- Persistent workspace folder (`./workspace` → `/workspace` in container)
- Interactive terminal access

### Initialize IoT Edge solution
```powershell
docker-compose run --rm iotedge-dev iotedgedev solution init --template c
```

### Edit .env file
- update the container registry settings:
    - CONTAINER_REGISTRY_USERNAME="\<your-registry-username\>"
    - CONTAINER_REGISTRY_PASSWORD="\<your-registry-password\>"
    - CONTAINER_REGISTRY_ADDRESS="\<your-registry-address\>"
- set the default platform to arm64v8: DEFAULT_PLATFORM="arm64v8"
- set deployment target: IOTHUB_DEPLOYMENT_TARGET_CONDITION="deviceId='\<your-device-id\>'"


### Add module
```powershell
docker-compose run --rm iotedge-dev iotedgedev   solution add -t c <module-name>
```

### Build the module image
```powershell
docker-compose run --rm iotedge-dev iotedgedev solution build
```

### Push the module image
```powershell
docker-compose run --rm iotedge-dev iotedgedev solution push
```

### Publish the deployment to IoT Hub
```powershell
docker-compose run --rm iotedge-dev iotedgedev iothub deploy -p 1 -n <name of deployment>
```
dock
### Optional

#### Access interactive shell
```powershell
docker-compose exec iotedge-dev bash
```

#### Stop and remove the container
```powershell
docker-compose down
```
