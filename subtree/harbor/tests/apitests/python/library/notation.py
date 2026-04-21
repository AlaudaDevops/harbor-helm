# -*- coding: utf-8 -*-
import os
import base

def generate_cert():
    command = ["notation", "cert", "generate-test", "--default", "wabbit-networks.io"]
    base.run_command(command)

def sign_artifact(artifact):
    if os.environ.get("HARBOR_HOST_SCHEMA") == "http":
        insecure = ["--insecure-registry"]
    else:
        insecure = []

    command = ["notation", "sign", *insecure, "-d", "--allow-referrers-api", artifact]
    base.run_command(command)
