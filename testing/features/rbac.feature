# language: zh-CN
@rbac
@e2e
@permission
功能: harbor 实例 RBAC 权限验证

    @automated
    @priority-high
    @harbor-rbac-platform-admin
    @allure.label.case_id:harbor-rbac-platform-admin
    场景: 验证平台管理员的权限
        假定 集群已存在存储类
        并且 命名空间 "harbor-rbac-platform-admin" 已存在
        并且 创建 "平台管理员" ServiceAccount 和 Token
            """
            name: platform-admin-sa
            namespace: harbor-rbac-platform-admin
            role: platform-admin
            """
        当 使用 "平台管理员" Token 创建 harbor 实例
            """
            instanceName: rbac-harbortest-platformadmin
            namespace: harbor-rbac-platform-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """
        那么 "平台管理员" 应该能够创建 harbor 实例
        并且 "平台管理员" 应该能够查看 harbor 实例
            """
            instanceName: rbac-harbortest-platformadmin
            namespace: harbor-rbac-platform-admin
            cluster: <config.acp.cluster>
            """

    @automated
    @priority-high
    @harbor-rbac-ns-admin
    @allure.label.case_id:harbor-rbac-ns-admin
    场景: 验证命名空间管理员的权限
        假定 集群已存在存储类
        并且 命名空间 "harbor-rbac-ns-admin" 已存在
        并且 创建 "命名空间管理员" ServiceAccount 和 Token
            """
            name: ns-admin-sa
            namespace: harbor-rbac-ns-admin
            role: ns-admin
            """
        那么 "命名空间管理员" 不应该能够创建 harbor 实例
            """
            instanceName: rbac-harbortest-nsadmin
            namespace: harbor-rbac-ns-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """
        
        并且 创建 "平台管理员" ServiceAccount 和 Token
            """
            name: platform-admin-sa
            namespace: harbor-rbac-ns-admin
            role: platform-admin
            """
        当 使用 "平台管理员" Token 创建 harbor 实例
            """
            instanceName: rbac-harbortest-nsadmin
            namespace: harbor-rbac-ns-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """
        并且 "命名空间管理员" 应该能够查看 harbor 实例
            """
            instanceName: rbac-harbortest-nsadmin
            namespace: harbor-rbac-ns-admin
            cluster: <config.acp.cluster>
            """
        并且 "命名空间管理员" 应该能够更新 harbor 实例
            """
            instanceName: rbac-harbortest-nsadmin
            namespace: harbor-rbac-ns-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """

    @automated
    @priority-high
    @harbor-rbac-project-admin
    @allure.label.case_id:harbor-rbac-project-admin
    场景: 验证项目管理员的权限
        假定 集群已存在存储类
        并且 命名空间 "harbor-rbac-project-admin" 已存在
        并且 创建 "项目管理员" ServiceAccount 和 Token
            """
            name: project-admin-sa
            namespace: harbor-rbac-project-admin
            role: project-admin
            """
        那么 "项目管理员" 不应该能够创建 harbor 实例
            """
            instanceName: rbac-harbortest-projectadmin
            namespace: harbor-rbac-project-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """
        
        并且 创建 "平台管理员" ServiceAccount 和 Token
            """
            name: platform-admin-sa
            namespace: harbor-rbac-project-admin
            role: platform-admin
            """
        当 使用 "平台管理员" Token 创建 harbor 实例
            """
            instanceName: rbac-harbortest-projectadmin
            namespace: harbor-rbac-project-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """
        并且 "项目管理员" 应该能够查看 harbor 实例
            """
            instanceName: rbac-harbortest-projectadmin
            namespace: harbor-rbac-project-admin
            cluster: <config.acp.cluster>
            """
        并且 "项目管理员" 应该能够更新 harbor 实例
            """
            instanceName: rbac-harbortest-projectadmin
            namespace: harbor-rbac-project-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """

    @automated
    @priority-high
    @harbor-rbac-developer
    @allure.label.case_id:harbor-rbac-developer
    场景: 验证开发人员的权限
        假定 集群已存在存储类
        并且 命名空间 "harbor-rbac-developer" 已存在
        并且 创建 "开发人员" ServiceAccount 和 Token
            """
            name: developer-sa
            namespace: harbor-rbac-developer
            role: developer
            """
        那么 "开发人员" 不应该能够创建 harbor 实例
            """
            instanceName: rbac-harbortest-developer
            namespace: harbor-rbac-developer
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """
        并且 创建 "平台管理员" ServiceAccount 和 Token
            """
            name: platform-admin-sa
            namespace: harbor-rbac-developer
            role: platform-admin
            """
        当 使用 "平台管理员" Token 创建 harbor 实例
            """
            instanceName: rbac-harbortest-developer
            namespace: harbor-rbac-developer
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """
        并且 "开发人员" 应该能够查看 harbor 实例
            """
            instanceName: rbac-harbortest-developer
            namespace: harbor-rbac-developer
            cluster: <config.acp.cluster>
            """
        并且 "开发人员" 不应该能够更新 harbor 实例
            """
            instanceName: rbac-harbortest-developer
            namespace: harbor-rbac-developer
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """

    @automated
    @priority-high
    @harbor-rbac-auditor
    @allure.label.case_id:harbor-rbac-auditor
    场景: 验证审计人员的权限
        假定 集群已存在存储类
        并且 命名空间 "harbor-rbac-auditor" 已存在
        并且 创建 "审计人员" ServiceAccount 和 Token
            """
            name: auditor-sa
            namespace: harbor-rbac-auditor
            role: auditor
            """
        那么 "审计人员" 不应该能够创建 harbor 实例
            """
            instanceName: rbac-harbortest-auditor
            namespace: harbor-rbac-auditor
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """
        并且 创建 "平台管理员" ServiceAccount 和 Token
            """
            name: platform-admin-sa
            namespace: harbor-rbac-auditor
            role: platform-admin
            """
        当 使用 "平台管理员" Token 创建 harbor 实例
            """
            instanceName: rbac-harbortest-auditor
            namespace: harbor-rbac-auditor
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """
        并且 "审计人员" 应该能够查看 harbor 实例
            """
            instanceName: rbac-harbortest-auditor
            namespace: harbor-rbac-auditor
            cluster: <config.acp.cluster>
            """
        并且 "审计人员" 不应该能够更新 harbor 实例
            """
            instanceName: rbac-harbortest-auditor
            namespace: harbor-rbac-auditor
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-harbor.yaml
            """
