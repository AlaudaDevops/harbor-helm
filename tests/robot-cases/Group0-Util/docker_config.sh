#!/bin/bash

if [ -z "$HARBOR_HOST" ]; then
    echo "Error: HARBOR_HOST environment variable is not set"
    exit 1
fi

if [ -z "$HARBOR_HOST_SCHEMA" ]; then
    echo "Error: HARBOR_HOST_SCHEMA environment variable is not set"
    exit 1
fi

mkdir -p /etc/docker

if [ "$HARBOR_HOST_SCHEMA" = "http" ]; then
    cat > /etc/docker/daemon.json <<EOF
{
    "insecure-registries": ["0.0.0.0/0", "${HARBOR_HOST}"],
    "default-shm-size": "256m"
}
EOF
else
    cat > /etc/docker/daemon.json <<EOF
{
    "default-shm-size": "256m"
}
EOF
fi

echo "Docker daemon configuration updated:"
cat /etc/docker/daemon.json

exit 0