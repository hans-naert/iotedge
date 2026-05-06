# IoT Edge Dev Container Usage

This workspace uses a Docker container to run `iotedgedev` commands with the project files mapped from the host.

The docker container of Microsoft is used. For more information check [Microsoft Learn: Tutorial – Develop IoT Edge modules using Visual Studio Code](https://learn.microsoft.com/en-us/azure/iot-edge/tutorial-develop-for-linux?view=iotedge-1.4&tabs=c&pivots=iotedge-dev-cli)

For general information, see the **docker-microsoft branch**.

---

## Why is the build so slow?

The default build runs in a QEMU virtual machine. This is necessary because ARM instructions need to be generated on an x86/x64 development environment. QEMU emulates an ARM processor, but this is very slow.

**Solution: Cross-compilation**

Cross-compilation uses an x86 compiler that directly generates ARM instructions, without emulation. This makes the build much faster (minutes instead of hours).

---

## Cross-Compilation for ARM64 (Recommended)

This method builds arm64 images **on your x64 development machine** without QEMU emulation during build, resulting in fast native-speed compilation.

### Required Files

- **Dockerfile.sdk-arm64**: Generates a container with a cross-compiler toolchain
- **Dockerfile.arm64v8.cross**: Place this file in each module folder
- **module.json**: Update with: `"arm64v8": "./Dockerfile.arm64v8.cross"`
- **CMakeLists.txt**: Use the modified CMakeLists.txt in the module folder

### Step 1: Build the SDK Image (once)

Install the QEMU emulator
```powershell
docker run --privileged --rm tonistiigi/binfmt --install arm64
```

The SDK image contains the cross-compiler toolchain, arm64 sysroot, and all dependencies. Build it **once** and reuse for all modules:

```powershell
cd workspace/iotedge-solution
docker build -f Dockerfile.sdk-arm64 -t iotedge-sdk-arm64:latest .
```

This creates:
- `/opt/arm64-rootfs` — sysroot with arm64 libraries + headers for compilation
- `/opt/arm64-runtime` — runtime-only libraries for the final image
- Cross-compiler: `aarch64-linux-gnu-gcc`

### Step 2: Configure Module

For each module:
1. Place `Dockerfile.arm64v8.cross` in the module folder
2. Update `module.json`: add or change: `"arm64v8": "./Dockerfile.arm64v8.cross"`
3. Use the modified `CMakeLists.txt`

### Step 3: Build Module Images

**Preferred: via iotedgedev** (if you configured module.json correctly with `"arm64v8": "./Dockerfile.arm64v8.cross"`):
```powershell
cd workspace/iotedge-solution
docker-compose run --rm iotedge-dev iotedgedev solution build
```

**Alternative: direct docker commands**

Each module now has a `Dockerfile.arm64v8.cross` that uses the SDK image:

```powershell
# Build filtermodule
cd workspace/iotedge-solution/modules/filtermodule
docker build -f Dockerfile.arm64v8.cross -t filtermodule:arm64 .

# Build module_student
cd workspace/iotedge-solution/modules/module_student
docker build -f Dockerfile.arm64v8.cross -t module_student:arm64 .
```

### Step 4: Push to Container Registry

**Preferred: via iotedgedev**:
```powershell
cd workspace/iotedge-solution
docker-compose run --rm iotedge-dev iotedgedev push
```

**Alternative: direct docker commands**

```powershell
# Tag for your registry
docker tag filtermodule:arm64 <your-registry>/filtermodule:arm64
docker push <your-registry>/filtermodule:arm64
```

**Note: Cleaning up old images on Raspberry Pi**

If you updated existing modules, remove old images on the device to force pulling new versions:

```bash
# On the Raspberry Pi
sudo iotedge system stop
sudo docker rm -f $(docker ps -aq)  # Remove all containers
sudo docker rmi <image-name>         # Remove specific old image
sudo iotedge system restart
```

### Step 5: Deploy to IoT Edge Device

Deploy the modules to your IoT Edge device. This is needed when:
- Version numbers are changed in module.json
- New modules are added or removed
- Module configuration is updated
- Initial deployment

**Preferred: via iotedgedev**:
```powershell
cd workspace/iotedge-solution
docker-compose run --rm iotedge-dev iotedgedev deploy
```

**Alternative: Azure Portal (GUI)**
1. Navigate to Azure Portal → IoT Hub → IoT Edge
2. Select your device
3. Click "Set modules"
4. Add or update module images
5. Review and create deployment

**Alternative: Azure CLI**
```powershell
az iot edge set-modules --device-id <device-id> --hub-name <hub-name> --content deployment.template.json
```
