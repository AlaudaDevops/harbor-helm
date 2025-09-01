# language: zh-CN

@e2e
@harbor-operator-deploy-use-mw-pg-redis
功能: 使用数据服务的pg和redis部署Harbor


  @smoke
  @automated
  @priority-high
  @allure.label.case_id:harbor-operator-deploy-use-mw-pg-redis
  场景: 使用数据服务的pg和redis部署harbor
    假定 命名空间 "testing-harbor-mw-<template.{{randAlphaNum 4 | toLower}}>" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    并且 已导入 "pg secret" 资源: "./testdata/resources/mw-pg-secret.yaml"
    并且 已导入 "redis secret" 资源: "./testdata/resources/mw-redis-secret.yaml"
    并且 已导入 "database" 资源: "./testdata/snippets/job-create-db.yaml"
    并且 已导入 "harbor实例" 资源: "./testdata/snippets/use-mw-pg-redis-deploy-harbor.yaml"
    那么 "harbor-mw" 组件检查通过
    并且 "harbor" 可以正常访问
      """
      url: http://<node.ip.random.readable>:<nodeport.http>
      timeout: 10m
      """
    并且 Pod 资源检查通过
      | name                 | path            | value           |
      | harbor-mw-registry   | $.spec.nodeName | <node.name.random> |
      | harbor-mw-jobservice | $.spec.nodeName | <node.name.random> |
      | harbor-mw-trivy      | $.spec.nodeName | <node.name.random> |