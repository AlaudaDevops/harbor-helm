# -*- coding: utf-8 -*-
import os
import base


def helm_registry_login(ip, user, password):
    command = ["helm", "registry", "login", ip, "-u", user, "-p", password, "--insecure"]
    base.run_command(command)

def helm_package(file_path):
    command = ["helm", "package", file_path]
    base.run_command(command)

def helm_push(file_path, ip, project_name):
    command = ["helm", "push", file_path, "oci://{}/{}".format(ip, project_name), *insecure_opt()]
    base.run_command(command)

def insecure_opt():
    schema = os.environ.get("HARBOR_HOST_SCHEMA", "https")
    if schema == "http":
        return  ["--plain-http"]
    return ["--insecure-skip-tls-verify"]
