# language: zh-CN
@harbor-chart-deploy
@harbor-chart-deploy-redis
功能: 支持使用不同模式的 Redis 部署 harbor

  @automated
  @priority-high
  @harbor-chart-deploy-redis-tls
  @allure.label.case_id:harbor-chart-deploy-redis-tls
  场景: 使用外部带 TLS 的 Redis 方式部署 harbor
    假定 命名空间 "testing-harbor-redis-tls-<template.{{randAlphaNum 4 | toLower}}>" 已存在
    并且 已导入 "Redis TLS 证书" 资源: "./testdata/resources/secret-redis-tls-assets.yaml"
    并且 已导入 "Redis TLS 服务" 资源: "./testdata/resources/redis-tls-server.yaml"
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    并且 已导入 "redis-password" 资源: "./testdata/resources/secret-redis-password.yaml"
    当 使用 helm 部署实例到 "testing-harbor-redis-tls-<template.{{randAlphaNum 4 | toLower}}>" 命名空间
      """
      chartPath: ../
      releaseName: harbor-redis-tls
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-storage-hostpath.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-redis-tls.yaml
      """
    那么 "harbor-redis-tls" 组件检查通过
    并且 "harbor" 可以正常访问
      """
      url: http://<node.ip.random.readable>:<nodeport.http>
      timeout: 10m
      """
    并且 执行 "harbor 官方 e2e" 脚本成功
      | command                                                                                                   |
      | bash ./testdata/script/run-harbor-e2e.sh http <node.ip.random.readable>:<nodeport.http> Harbor12345 harbor-redis-tls |
