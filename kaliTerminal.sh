#!/bin/bash

CURRENT_USER=$(whoami)
echo "Detected username: $CURRENT_USER"


check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "Docker is not running. Attempting to start Docker Desktop..."
        open -a Docker
        echo "Waiting for Docker to start..."
        local count=0
        local max_attempts=30
        while [ $count -lt $max_attempts ]; do
            if docker info > /dev/null 2>&1; then
                echo "Docker is now running!"
                return 0
            fi
            sleep 2
            ((count++))
        done
        echo "Failed to start Docker after $max_attempts attempts."
        exit 1
    else
        echo "Docker is running"
    fi
}

check_docker

if ! docker images | grep -q "kalilinux/kali-rolling"; then
    echo "Pulling Kali Linux image..."
    docker pull docker.io/kalilinux/kali-rolling
fi


if docker ps -a | grep -q "kali-container"; then
    echo "Removing existing kali-container..."
    docker rm -f kali-container
fi

echo "Starting Kali Linux container (no volume mount)..."
echo "Using host network"
echo "You'll have full root access in the container"

docker run -it \
    --name kali-container \
    --network host \
    -v /mnt/homes/$CURRENT_USER/goinfre/rootKali:/root/workdir \
    kalilinux/kali-rolling \
    /bin/bash