# Build the image
docker build -t iotedge-dev:latest .

# Run the container
docker run -it -v /var/run/docker.sock:/var/run/docker.sock iotedge-dev:latest

# Inside the container, run the setup script
bash /workspace/setup.sh