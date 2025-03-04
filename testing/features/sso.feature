# language: zh-CN
@harbor-chart-deploy
@e2e
功能: 支持 SSO 模式部署 harbor

    @automated
    @priority-high
    @harbor-chart-deploy-sso
    场景: 使用 SSO 模式部署 harbor
        假定 集群已存在存储类
        并且 命名空间 "harbor-sso" 已存在
        并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
        并且 执行 "sso 配置" 脚本成功
            | command                                                                                                                                                                 |
            | bash ./testdata/script/prepare-sso-config.sh '<config.{{.acp.baseUrl}}>' '<config.{{.acp.token}}>' '<config.{{.acp.cluster}}>' 'http://<node.ip.first>:<nodeport.http>' |
            | mkdir -p output/images                                                                                                                                                  |
        当 使用 helm 部署实例到 "harbor-sso" 命名空间
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
            url: http://<node.ip.first>:<nodeport.http>
            timeout: 10m
            """
        并且 SSO 测试通过
            """
            url: http://<node.ip.first>:<nodeport.http>
            acpURL: <config.{{.acp.baseUrl}}>
            acpUser: <config.{{.acp.username}}>
            acpPassword: <config.{{.acp.password}}>
            timeout: 10m
            headless: true
            """
