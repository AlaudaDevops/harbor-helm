# language: zh-CN

@harbor-chart-deploy
@harbor-chart-deploy-storage
功能: 支持多种存储类型部署 harbor

  @automated
  @priority-high
  @harbor-chart-deploy-storage-sc
  @allure.label.case_id:harbor-chart-deploy-storage-sc
  场景: 使用存储类方式部署 harbor
    假定 集群已存在存储类
    并且 命名空间 "testing-harbor-sc-<template.{{randAlphaNum 4 | toLower}}>" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    当 使用 helm 部署实例到 "testing-harbor-sc-<template.{{randAlphaNum 4 | toLower}}>" 命名空间
      """
      chartPath: ../
      releaseName: harbor-sc
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-storage-sc.yaml
      """
    那么 "harbor-sc" 组件检查通过
    并且 "harbor" 可以正常访问
      """
      url: http://<node.ip.random.readable>:<nodeport.http>
      timeout: 10m
      """
    并且 Pod 资源检查通过
      | name                 | path                                                                            | value                  |
      | harbor-sc-registry   | $.spec.volumes[?(@.name == 'registry-data')][0].persistentVolumeClaim.claimName | harbor-sc-registry     |
      | harbor-sc-jobservice | $.spec.volumes[?(@.name == 'job-logs')][0].persistentVolumeClaim.claimName      | harbor-sc-jobservice   |
      | harbor-sc-trivy      | $.spec.volumes[?(@.name == 'data')][0].persistentVolumeClaim.claimName          | data-harbor-sc-trivy-0 |
    并且 执行 "harbor 官方 e2e" 脚本成功
       | command                                                                                             |
       | bash ./testdata/script/run-harbor-e2e.sh http <node.ip.random.readable>:<nodeport.http> Harbor12345 harbor-sc |

  @smoke
  @automated
  @priority-high
  @harbor-chart-deploy-storage-hostpath
  @allure.label.case_id:harbor-chart-deploy-storage-hostpath
  场景: 使用 hostpath 方式部署 harbor
    假定 命名空间 "testing-harbor-hostpath-<template.{{randAlphaNum 4 | toLower}}>" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    当 使用 helm 部署实例到 "testing-harbor-hostpath-<template.{{randAlphaNum 4 | toLower}}>" 命名空间
      """
      chartPath: ../
      releaseName: harbor-hostpath
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-storage-hostpath.yaml
      """
    那么 "harbor-hostpath" 组件检查通过
    并且 "harbor" 可以正常访问
      """
      url: http://<node.ip.random.readable>:<nodeport.http>
      timeout: 10m
      """
    并且 Pod 资源检查通过
      | name                       | path            | value           |
      | harbor-hostpath-registry   | $.spec.nodeName | <node.name.random> |
      | harbor-hostpath-jobservice | $.spec.nodeName | <node.name.random> |
      | harbor-hostpath-trivy      | $.spec.nodeName | <node.name.random> |
    并且 执行 "harbor 官方 e2e" 脚本成功
       | command                                                                                                   |
       | bash ./testdata/script/run-harbor-e2e.sh http <node.ip.random.readable>:<nodeport.http> Harbor12345 harbor-hostpath |

  @automated
  @priority-high
  @harbor-chart-deploy-storage-pvc
  @allure.label.case_id:harbor-chart-deploy-storage-pvc
  场景: 使用指定 pvc 的方式部署 harbor
    假定 命名空间 "testing-harbor-pvc-<template.{{randAlphaNum 4 | toLower}}>" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    并且 已导入 "pvc" 资源: "./testdata/resources/storage-pvc.yaml"
    当 使用 helm 部署实例到 "testing-harbor-pvc-<template.{{randAlphaNum 4 | toLower}}>" 命名空间
      """
      chartPath: ../
      releaseName: harbor-pvc
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-storage-pvc.yaml
      """
    那么 "harbor-pvc" 组件检查通过
    并且 "harbor" 可以正常访问
      """
      url: http://<node.ip.random.readable>:<nodeport.http>
      timeout: 10m
      """
    并且 Pod 资源检查通过
      | name                  | path                                                                            | value          |
      | harbor-pvc-registry   | $.spec.volumes[?(@.name == 'registry-data')][0].persistentVolumeClaim.claimName | pvc-registry   |
      | harbor-pvc-jobservice | $.spec.volumes[?(@.name == 'job-logs')][0].persistentVolumeClaim.claimName      | pvc-jobservice |
      | harbor-pvc-trivy      | $.spec.volumes[?(@.name == 'data')][0].persistentVolumeClaim.claimName          | pvc-trivy      |
    并且 执行 "harbor 官方 e2e" 脚本成功
      | command                                                                                              |
      | bash ./testdata/script/run-harbor-e2e.sh http <node.ip.random.readable>:<nodeport.http> Harbor12345 harbor-pvc |

  @smoke
  @automated
  @priority-high
  @harbor-chart-deploy-storage-s3
  @allure.label.case_id:harbor-chart-deploy-storage-s3
  场景: 使用对象存储方式部署 harbor
    假定 命名空间 "testing-harbor-s3-<template.{{randAlphaNum 4 | toLower}}>" 已存在
    并且 已导入 "Minio 对象存储" 资源: "./testdata/resources/minio-server.yaml"
    并且 已导入 "Minio Bucket 初始化" 资源: "./testdata/resources/minio-bucket-init.yaml"
    并且 已导入 "Minio 凭据" 资源: "./testdata/resources/secret-minio-password.yaml"
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    当 使用 helm 部署实例到 "testing-harbor-s3-<template.{{randAlphaNum 4 | toLower}}>" 命名空间
      """
      chartPath: ../
      releaseName: harbor-s3
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-storage-s3.yaml
      """
    那么 "harbor-s3" 组件检查通过
    并且 "harbor" 可以正常访问
      """
      url: http://<node.ip.random.readable>:<nodeport.http>
      timeout: 10m
      """
    并且 Pod 资源检查通过
      | name                 | path                                                          | value          |
      | harbor-s3-registry   | $.spec.volumes[?(@.name == 'registry-data')][0].emptyDir      |                |
      | harbor-s3-registry   | $.spec.volumes[?(@.name == 's3-secret')][0].secret.secretName | harbor-minio   |
      | harbor-s3-jobservice | $.spec.volumes[?(@.name == 'job-logs')][0].emptyDir           |                |
      | harbor-s3-trivy      | $.spec.volumes[?(@.name == 'data')][0].emptyDir               |                |
    并且 执行 "harbor 官方 e2e" 脚本成功
       | command                                                                                             |
       | bash ./testdata/script/run-harbor-e2e.sh http <node.ip.random.readable>:<nodeport.http> Harbor12345 harbor-sc |
