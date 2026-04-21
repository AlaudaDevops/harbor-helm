#!/bin/sh

set -e

/harbor/install_cert.sh

source /harbor/exports_env_in_dir.sh /etc/env-files/

exec /harbor/harbor_core
