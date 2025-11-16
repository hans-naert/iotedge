# register your device
[Create and provision an IoT Edge device on Linux using symmetric keys](https://learn.microsoft.com/en-us/azure/iot-edge/how-to-provision-single-device-linux-symmetric?view=iotedge-1.5&tabs=azure-portal%2Cubuntu)
```console
sudo iotedge config mp --connection-string 'PASTE_DEVICE_CONNECTION_STRING_HERE'
```

# instructions
Follow the tutorial on https://learn.microsoft.com/en-us/azure/iot-edge/tutorial-develop-for-linux?view=iotedge-1.4&tabs=c&pivots=iotedge-dev-cli,
details described below.

## Generate virtual envirionment
```console
winget install Python.Python.3.12
python -3.12 -m venv .\venv
```

## Activate virtual environment
```console
.\venv\Scripts\activate
```

## Install requirements in virtual environment
```console
pip install -r requirements.txt
```

Requirements.txt bevat: 
- iotedgedev
- setuptools

## Install azure-cli and login

Installeer Azure-CLI 2.73 (bevat Python 3.12): https://github.com/Azure/azure-cli/releases/download/azure-cli-2.73.0/azure-cli-2.73.0-x64.msi

```console
az login
```

Bij fout ivm TENANT-ID:
```console
az login --tenant <TENANT-ID>
```

## Install azure-iot
```console
az extension add --name azure-iot
```

## if error urllib3.packages.six not found
```console
pip uninstall urllib3
pip install urllib3
```

## generate iotedge solution with iotedgedev
```console
mkdir iotedge-solution
cd iotedge-solution
iotedgedev solution init --template c
```

## update .env file
fill the keys for IoT Hub, IoT Edge device and container registry in .env file

## sign in with docker and azure CLI to the container registry
```
docker login -u <ACR username> -p <ACR password> <ACR login server>
az acr login -n <ACR registry name>
```

## build the module Docker image
```
docker buildx build --platform linux/arm64/v8 --rm -f "./modules/filtermodule/Dockerfile.arm64v8" -t <ACR login server>/filtermodule:latest "./modules/filtermodule"
```

## push the Docker image
```
docker push --platform linux/arm64/v8 <ACR login server>/filtermodule:latest
```

## deploy to the edge device

Deploy with the GUI or with Azure CLI.

If using the Azure CLI the deployment file needs to be adapted as described in the tutorial and place the correct image name for the filtermodule.
```
az iot edge set-modules --hub-name <my-iot-hub> --device-id <my-device> --content ./deployment.template.json
```

![alt text](deploy_module.png "Image showing deployment of module in Azure portal")

## check that the module is running on Raspberry Pi

```bash
pi@rpi-hn:~ $ iotedge list
NAME             STATUS           DESCRIPTION      Config
edgeAgent        running          Up 2 hours       mcr.microsoft.com/azureiotedge-agent:1.5
edgeHub          running          Up 2 hours       mcr.microsoft.com/azureiotedge-hub:1.5
filtermodule     running          Up 7 minutes     criothubhn2023.azurecr.io/filtermodule:latest
```
