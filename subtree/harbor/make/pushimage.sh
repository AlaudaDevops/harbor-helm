#!/bin/bash

set +e
set -o noglob

if [ "$1" == "" ];then
  echo "This shell will push specific image to registry server."
  echo "Usage: #./pushimage [image tag] [registry username] [registry password]  [registry server]"
  exit 1
fi

#
# Set Colors
#

bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

red=$(tput setaf 1)
green=$(tput setaf 76)
white=$(tput setaf 7)
tan=$(tput setaf 202)
blue=$(tput setaf 25)

#
# Headers and Logging
#

underline() { printf "${underline}${bold}%s${reset}\n" "$@"
}
h1() { printf "\n${underline}${bold}${blue}%s${reset}\n" "$@"
}
h2() { printf "\n${underline}${bold}${white}%s${reset}\n" "$@"
}
debug() { printf "${white}%s${reset}\n" "$@"
}
info() { printf "${white}➜ %s${reset}\n" "$@"
}
success() { printf "${green}✔ %s${reset}\n" "$@"
}
error() { printf "${red}✖ %s${reset}\n" "$@"
}
warn() { printf "${tan}➜ %s${reset}\n" "$@"
}
bold() { printf "${bold}%s${reset}\n" "$@"
}
note() { printf "\n${underline}${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$@"
}


type_exists() {
  if [ $(type -P $1) ]; then
    return 0
  fi
  return 1
}

# Check variables
if [ -z $1 ]; then
  error "Please set the 'image' variable"
  exit 1
fi

if [ -z $2 ]; then
  error "Please set the 'username' variable"
  exit 1
fi

if [ -z $3 ]; then
  error "Please set the 'password' variable"
  exit 1
fi

if [ -z $4 ]; then
  info "Using default registry server (dockerhub)."
fi


# Check Podman is installed
if ! type_exists 'podman'; then
  error "Podman is not installed."
  info "Please install podman package."
  exit 1
fi

# Variables
IMAGE="$1"
USERNAME="$2"
PASSWORD="$3"
REGISTRY="$4"
PULL_BASE_FROM_PodmanHUB="$5"

set -e
set -x

# ----- Pushing image(s) -----
# see documentation :
#  - https://docs.podman.io/en/latest/markdown/podman-login.1.html
#  - https://docs.podman.io/en/latest/markdown/podman-push.1.html
#  - https://docs.podman.io/en/latest/markdown/podman-logout.1.html
# ---------------------------

# Push the OCI image
h2 "Pushing image to OCI registry"

PODMAN_PUSH="podman push $IMAGE"
info "$PODMAN_PUSH"
PODMAN_PUSH_OUTPUT=$($PODMAN_PUSH)

if [ $? -ne 0 ];then
  warn $PODMAN_PUSH_OUTPUT
  error "Pushing image $IMAGE failed";
else
  success "Pushing image $IMAGE succeeded";
fi

if [ "$PULL_BASE_FROM_PodmanHUB" == "true" ];then
  h2 "Remove local goharbor images"
  PODMAN_RMI="podman rmi -f $(podman images | grep "${IMAGE%:*}" | awk '{print $3}') -f"
  info "$PODMAN_RMI"
  Podman_RMI_OUTPUT=$($PODMAN_RMI)
  if [ $? -ne 0 ];then
    warn $Podman_RMI_OUTPUT
    error "Clean local goharbor images failed";
  else
    success "Clean local goharbor images succeeded";
  fi
fi

