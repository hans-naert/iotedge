# IoT Edge Dev Container Usage

This workspace uses a Docker container to run `iotedgedev` commands with the project files mapped from the host.

The docker container of Microsoft is used. For more information check [Microsoft Learn: Tutorial – Develop IoT Edge modules using Visual Studio Code](https://learn.microsoft.com/en-us/azure/iot-edge/tutorial-develop-for-linux?view=iotedge-1.4&tabs=c&pivots=iotedge-dev-cli)

---

## Cross-Compilation for ARM64 (Recommended)

This method builds arm64 images **on your x64 development machine** without QEMU emulation during build, resulting in fast native-speed compilation.

### Step 1: Build the SDK Image (once)

The SDK image contains the cross-compiler toolchain, arm64 sysroot, and all dependencies. Build it once and reuse for all modules:

```powershell
cd workspace/iotedge-solution
docker build -f Dockerfile.sdk-arm64 -t iotedge-sdk-arm64:latest .
```

This creates:
- `/opt/arm64-rootfs` — sysroot with arm64 libraries + headers for compilation
- `/opt/arm64-runtime` — runtime-only libraries for the final image
- Cross-compiler: `aarch64-linux-gnu-gcc`

### Step 2: Build Module Images

Each module has a `Dockerfile.arm64v8.cross` that uses the SDK image:

```powershell
# Build filtermodule
cd workspace/iotedge-solution/modules/filtermodule
docker build -f Dockerfile.arm64v8.cross -t filtermodule:arm64 .

# Build module_student
cd workspace/iotedge-solution/modules/module_student
docker build -f Dockerfile.arm64v8.cross -t module_student:arm64 .
```

### Step 3: Verify with QEMU (Optional)

Test the arm64 image on your x64 laptop using QEMU emulation:

```powershell
# Enable QEMU emulation (run once after Docker restart)
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Verify architecture
docker run --rm --platform linux/arm64 filtermodule:arm64 uname -m
# Expected output: aarch64

# Test the module binary (will fail without IoT Edge runtime, but proves it runs)
docker run --rm --platform linux/arm64 filtermodule:arm64 ./main
# Expected: "Environment IOTEDGE_AUTHSCHEME not set" error = binary works!
```

### Step 4: Push to Container Registry

```powershell
# Tag for your registry
docker tag filtermodule:arm64 <your-registry>/filtermodule:arm64
docker push <your-registry>/filtermodule:arm64
```

---

## Using iotedgedev Container (Alternative)

This method uses Microsoft's iotedgedev container with QEMU for arm64 builds.

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
docker-compose run --rm iotedge-dev iotedgedev solution add -t c <module-name>
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

### Optional

#### Access interactive shell
```powershell
docker-compose exec iotedge-dev bash
```

#### Stop and remove the container
```powershell
docker-compose down
```
