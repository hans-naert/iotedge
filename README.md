# instructions
## Generate virtual envirionment
```console
python -m venv .\venv
```

## Activate virtual environment
```console
.\venv\Scripts\activate
```

## Install requirements in virtual environment
```console
pip install -r requirements.txt
```

## Install azure-cli and login
```console
winget install -e --id Microsoft.AzureCLI
az login
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
iotedgedev solution init --template c
```