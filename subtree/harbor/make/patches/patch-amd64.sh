#!/bin/bash

set -e
change_base_image () {
    for file in `ls $1`
    do
        if [ -d $1"/"$file ]
        then
            change_base_image $1"/"$file
        elif [[ $file == *Dockerfile* ]]
        then
            sed -i 's/photon:5.0/build-harbor.alauda.cn\/ops\/photon:5-alauda-202507071048/' $1"/"$file
            sed -i 's/node:16.18.0/docker-mirrors.alauda.cn\/library\/node:16.18.0/' $1"/"$file

            echo $1"/"$file
        elif [[ $file == "docker-healthcheck.sh" ]]
        then
            sed -i '/host=/ s/$/\nhost="${host%%[[:space:]]*}"/' $1"/"$file
        fi
    done
}

change_base_image "make/photon"

# swagger

# renovate: datasource=golang-version depName=go
export GOLANG_IMAGE_VERSION=1.24.5

sed -i 's/registry.npmjs.org/build-nexus.alauda.cn\/repository\/npm\//g' "Makefile"
sed -i 's/BUILDBIN=true/BUILDBIN=false/g' "Makefile"
sed -i 's/PUSHBASEIMAGE=false/PUSHBASEIMAGE=true/g' "Makefile"
sed -i 's/BASEIMAGENAMESPACE=goharbor/BASEIMAGENAMESPACE \?= goharbor/g' "Makefile"
sed -i 's/IMAGENAMESPACE=goharbor/IMAGENAMESPACE \?= goharbor/g' "Makefile"
sed -i 's/TRIVYFLAG=false/TRIVYFLAG=true/g' "Makefile"
sed -i 's/=goharbor\//=build-harbor.alauda.cn\/devops\/goharbor-/g' "Makefile"
sed -i 's/--pull / /g' "Makefile"
sed -i 's/$(IMAGENAMESPACE)\//$(IMAGENAMESPACE)\/goharbor-/g' "Makefile"
sed -i "s/golang:1.24.4/docker-mirrors.alauda.cn\/library\/golang:${GOLANG_IMAGE_VERSION} /g" "Makefile"
sed -i 's/-v \$(BUILDPATH):\$(GOBUILDPATHINCONTAINER)/-v \$(BUILDPATH):\$(GOBUILDPATHINCONTAINER) -e GOPROXY=\$(GOPROXY)/' "Makefile"
sed -i '1 a GOPROXY=https://build-nexus.alauda.cn/repository/golang/,https://goproxy.cn,direct' "Makefile"

sed -i 's/compile: check_environment versions_prepare compile_core compile_jobservice compile_registryctl/compile: versions_prepare compile_core compile_jobservice compile_registryctl/g' "Makefile"
echo "AMD64 after change the Makefile is "
cat Makefile

sed -i 's/build: _build_prepare _build_db _build_portal _build_core _build_jobservice _build_log _build_nginx _build_registry _build_registryctl _build_trivy_adapter _build_redis _compile_and_build_exporter/build: _build_portal _build_core _build_jobservice _build_nginx _build_registry _build_registryctl _build_trivy_adapter _compile_and_build_exporter/g' "make/photon/Makefile"
sed -i '1 a TRIVYFLAG=true' "make/photon/Makefile"


sed -i 's/=goharbor\//=build-harbor.alauda.cn\/devops\/goharbor-/g' "make/photon/Makefile"
sed -i 's/BASEIMAGENAMESPACE=goharbor/BASEIMAGENAMESPACE \?= goharbor/g' "make/photon/Makefile"
sed -i 's/IMAGENAMESPACE=goharbor/IMAGENAMESPACE \?= goharbor/g' "make/photon/Makefile"
sed -i 's/$(IMAGENAMESPACE)\//$(IMAGENAMESPACE)\/goharbor-/g' "make/photon/Makefile"

echo "AMD64 after change the make/photon/Makefile is "
cat make/photon/Makefile

sed -i "s/golang:1.24.4/docker-mirrors.alauda.cn\/library\/golang:${GOLANG_IMAGE_VERSION} /g" "make/photon/trivy-adapter/Dockerfile.binary"
echo "AMD64 after change the make/photon/trivy-adapter/Dockerfile.binary "
cat make/photon/trivy-adapter/Dockerfile.binary

sed -i "s/golang:1.24.4/docker-mirrors.alauda.cn\/library\/golang:${GOLANG_IMAGE_VERSION} /g" "make/photon/registry/Dockerfile.binary"
echo "AMD64 after change the make/photon/registry/Dockerfile.binary "
cat make/photon/registry/Dockerfile.binary




