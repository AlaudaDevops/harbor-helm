# language: zh-CN
@harbor-chart-deploy
@e2e
@acp
功能: 支持 SSO 模式部署 harbor

    @e2e
    @automated
    @priority-high
    @harbor-chart-deploy-sso
    @allure.label.case_id:harbor-chart-deploy-sso
    场景: 使用 SSO 模式部署 harbor
        假定 集群已存在存储类
        并且 命名空间 "testing-harbor-sso-<template.{{randAlphaNum 4 | toLower}}>" 已存在
        并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
        并且 执行 "sso 配置" 脚本成功
            | command                                                                                                                                                                 |
            | bash ./testdata/script/prepare-sso-config.sh '<config.{{.acp.baseUrl}}>' '<config.{{.acp.token}}>' '<config.{{.acp.cluster}}>' 'http://<node.ip.random.readable>:<nodeport.http>' |
        当 使用 helm 部署实例到 "testing-harbor-sso-<template.{{randAlphaNum 4 | toLower}}>" 命名空间
            """
            chartPath: ../
            releaseName: harbor-sso
            values:
            - testdata/snippets/base-values.yaml
            - testdata/snippets/values-storage-hostpath.yaml
            - testdata/snippets/values-network-nodeport.yaml
            - testdata/snippets/values-sso.yaml
            """
        那么 "harbor-sso" 组件检查通过
        并且 "harbor" 可以正常访问
            """
            url: http://<node.ip.random.readable>:<nodeport.http>
            timeout: 10m
            """
        并且 SSO 测试通过
            """
            url: http://<node.ip.random.readable>:<nodeport.http>
            acpURL: <config.{{.acp.baseUrl}}>
            acpUser: <config.{{.acp.username}}>
            acpPassword: <config.{{.acp.password}}>
            timeout: 10m
            headless: true
            """
