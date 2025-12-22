#!/bin/bash

set +e

if [ -z $1 ]; then
  error "Please set the 'version' variable"
  exit 1
fi

VERSION="$1"

set -e

cd $(dirname $0)
cur=$PWD

# The temporary directory to clone Trivy source code
TEMP=$(mktemp -d ${TMPDIR-/tmp}/trivy.XXXXXX)
git clone --depth=1 -b $VERSION https://github.com/aquasecurity/trivy.git $TEMP

echo "Building Trivy binary based on golang..."
cp Dockerfile.trivy.binary $TEMP
docker build -f $TEMP/Dockerfile.trivy.binary -t trivy-golang $TEMP

echo "Copying Trivy binary from the container to the local directory..."
ID=$(docker create trivy-golang)
docker cp $ID:/go/src/github.com/aquasecurity/trivy/trivy binary
docker rm -f $ID
docker rmi -f trivy-golang

echo "Building Trivy binary finished successfully"

cd $cur
rm -rf $TEMP