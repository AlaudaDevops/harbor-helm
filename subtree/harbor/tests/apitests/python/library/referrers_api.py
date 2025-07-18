# -*- coding: utf-8 -*-
import requests

def call(harbor_url, project_name, repo_name, digest, artifactType=None, **kwargs):
    url=None
    auth = (kwargs.get("username"), kwargs.get("password"))
    if artifactType:
        artifactType = artifactType.replace("+", "%2B")
        url="{}/v2/{}/{}/referrers/{}?artifactType={}".format(harbor_url, project_name, repo_name, digest, artifactType)
    else:
        url="{}/v2/{}/{}/referrers/{}".format(harbor_url, project_name, repo_name, digest)
    return requests.get(url, auth=auth, verify=False)
