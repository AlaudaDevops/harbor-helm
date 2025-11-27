# language: zh-CN

@operator
@e2e
@harbor-operator-deploy
@allure.label.case_id:harbor-operator-deploy
功能: 测试 operator 部署 harbor 实例

    场景: 测试 operator 部署 harbor 实例
        假定 集群已存在存储类
        并且 命名空间 "testing-harbor-operator-<template.{{randAlphaNum 4 | toLower}}>" 已存在
        并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
        当 创建 "harbor 实例" 资源: "./testdata/harbor.yaml"
        那么 "harbor-operator" 可以正常访问
            """
            url: http://<node.ip.random.readable>:<nodeport.http>
            timeout: 15m
            """
        并且 "harbor-operator" 组件检查通过
        并且 "Harbor 模版" 资源检查通过
            |     kind  | apiVersion | name               | namespace    | path | value |
            | ConfigMap | v1         | harbor-template-ha | cpaas-system | $.metadata.name | harbor-template-ha |
            | ConfigMap | v1         | harbor-template-quickstart | cpaas-system | $.metadata.name | harbor-template-quickstart |
        并且 执行 "harbor 官方 e2e" 脚本成功
        | command                                                                                                   |
        | bash ./testdata/script/run-harbor-e2e.sh http <node.ip.random.readable>:<nodeport.http> Harbor12345 harbor-operator |
