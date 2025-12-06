#!/bin/bash
# Secure Docker login script using --password-stdin
# Usage: bash docker-login.sh <username> <password> <registry>

if [ $# -ne 3 ]; then
    echo "Usage: bash docker-login.sh <username> <password> <registry>"
    echo "Example: bash docker-login.sh containerregistryvives2025 'YOUR_PASSWORD' containerregistryvives2025.azurecr.io"
    exit 1
fi

USERNAME=$1
PASSWORD=$2
REGISTRY=$3

echo "Logging in to Docker registry: $REGISTRY"
echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin "$REGISTRY"

if [ $? -eq 0 ]; then
    echo "Successfully logged in to $REGISTRY"
else
    echo "Failed to login to $REGISTRY"
    exit 1
fi
