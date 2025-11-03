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

# The temporary directory to clone Trivy adapter source code
TEMP=$(mktemp -d ${TMPDIR-/tmp}/trivy-adapter.XXXXXX)
git clone --depth=1 -b $VERSION https://github.com/goharbor/harbor-scanner-trivy.git $TEMP

echo "Building Trivy adapter binary based on golang:1.24.4..."
cp Dockerfile.binary $TEMP
podamn build -f $TEMP/Dockerfile.binary -t trivy-adapter-golang $TEMP

echo "Copying Trivy adapter binary from the container to the local directory..."
ID=$(podamn create trivy-adapter-golang)
podamn cp $ID:/go/src/github.com/goharbor/harbor-scanner-trivy/scanner-trivy binary

podamn rm -f $ID
podamn rmi -f trivy-adapter-golang

echo "Building Trivy adapter binary finished successfully"
cd $cur
rm -rf $TEMP
