#!/bin/bash

set -e

echo "ARM64 after change  make/photon/Makefile is "
cat make/photon/Makefile

sed -i 's/--rm/--rm --env CGO_ENABLED=0 --env GOOS=linux --env GOARCH=arm64/g' "Makefile"
# build base
sed -i 's/docker push/echo /g' "Makefile"
echo "ARM64 after change Makefile is "
cat Makefile

sed -i 's/CGO_ENABLED=0/GOOS=linux GOARCH=arm64 CGO_ENABLED=0/g' "make/photon/registry/Dockerfile.binary"
echo "ARM64 after change make/photon/registry/Dockerfile.binary is "
cat make/photon/registry/Dockerfile.binary

sed -i 's/CGO_ENABLED=0/GOOS=linux GOARCH=arm64 CGO_ENABLED=0/g' "make/photon/trivy-adapter/Dockerfile.binary"
echo "ARM64 after change make/photon/trivy-adapter/Dockerfile.binary is "
cat make/photon/trivy-adapter/Dockerfile.binary

sed -i 's/CGO_ENABLED=0/GOOS=linux GOARCH=arm64 CGO_ENABLED=0/g' "make/photon/trivy-adapter/Dockerfile.trivy.binary"
echo "ARM64 after change make/photon/trivy-adapter/Dockerfile.trivy.binary is "
cat make/photon/trivy-adapter/Dockerfile.trivy.binary

sed -i 's#_Linux-64bit.tar.gz#_Linux-ARM64.tar.gz#g' "Makefile"
echo "after change trivy download alauda url"
cat Makefile

# exporter build
sed -i 's/GOARCH=amd64/GOARCH=arm64/g' "make/photon/exporter/Dockerfile"

