#!/bin/sh

set -e

/home/scanner/install_cert.sh

source /home/scanner/exports_env_in_dir.sh /etc/env-files/

exec /home/scanner/bin/scanner-trivy
