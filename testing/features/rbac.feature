# language: zh-CN
@rbac
@e2e
@permission
功能: nexus 实例 RBAC 权限验证

    @automated
    @priority-high
    @nexus-rbac-platform-admin
    @allure.label.case_id:nexus-rbac-platform-admin
    场景: 验证平台管理员的权限
        假定 集群已存在存储类
        并且 命名空间 "nexus-rbac-platform-admin" 已存在
        并且 创建 "平台管理员" ServiceAccount 和 Token
            """
            name: platform-admin-sa
            namespace: nexus-rbac-platform-admin
            role: platform-admin
            """
        当 使用 "平台管理员" Token 创建 nexus 实例
            """
            instanceName: rbac-nexustest-platformadmin
            namespace: nexus-rbac-platform-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """
        那么 "平台管理员" 应该能够创建 nexus 实例
        并且 "平台管理员" 应该能够查看 nexus 实例
            """
            instanceName: rbac-nexustest-platformadmin
            namespace: nexus-rbac-platform-admin
            cluster: <config.acp.cluster>
            """

    @automated
    @priority-high
    @nexus-rbac-ns-admin
    @allure.label.case_id:nexus-rbac-ns-admin
    场景: 验证命名空间管理员的权限
        假定 集群已存在存储类
        并且 命名空间 "nexus-rbac-ns-admin" 已存在
        并且 创建 "命名空间管理员" ServiceAccount 和 Token
            """
            name: ns-admin-sa
            namespace: nexus-rbac-ns-admin
            role: ns-admin
            """
        那么 "命名空间管理员" 不应该能够创建 nexus 实例
            """
            instanceName: rbac-nexustest-nsadmin
            namespace: nexus-rbac-ns-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """
        
        并且 创建 "平台管理员" ServiceAccount 和 Token
            """
            name: platform-admin-sa
            namespace: nexus-rbac-ns-admin
            role: platform-admin
            """
        当 使用 "平台管理员" Token 创建 nexus 实例
            """
            instanceName: rbac-nexustest-nsadmin
            namespace: nexus-rbac-ns-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """
        并且 "命名空间管理员" 应该能够查看 nexus 实例
            """
            instanceName: rbac-nexustest-nsadmin
            namespace: nexus-rbac-ns-admin
            cluster: <config.acp.cluster>
            """
        并且 "命名空间管理员" 应该能够更新 nexus 实例
            """
            instanceName: rbac-nexustest-nsadmin
            namespace: nexus-rbac-ns-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """

    @automated
    @priority-high
    @nexus-rbac-project-admin
    @allure.label.case_id:nexus-rbac-project-admin
    场景: 验证项目管理员的权限
        假定 集群已存在存储类
        并且 命名空间 "nexus-rbac-project-admin" 已存在
        并且 创建 "项目管理员" ServiceAccount 和 Token
            """
            name: project-admin-sa
            namespace: nexus-rbac-project-admin
            role: project-admin
            """
        那么 "项目管理员" 不应该能够创建 nexus 实例
            """
            instanceName: rbac-nexustest-projectadmin
            namespace: nexus-rbac-project-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """
        
        并且 创建 "平台管理员" ServiceAccount 和 Token
            """
            name: platform-admin-sa
            namespace: nexus-rbac-project-admin
            role: platform-admin
            """
        当 使用 "平台管理员" Token 创建 nexus 实例
            """
            instanceName: rbac-nexustest-projectadmin
            namespace: nexus-rbac-project-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """
        并且 "项目管理员" 应该能够查看 nexus 实例
            """
            instanceName: rbac-nexustest-projectadmin
            namespace: nexus-rbac-project-admin
            cluster: <config.acp.cluster>
            """
        并且 "项目管理员" 应该能够更新 nexus 实例
            """
            instanceName: rbac-nexustest-projectadmin
            namespace: nexus-rbac-project-admin
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """

    @automated
    @priority-high
    @nexus-rbac-developer
    @allure.label.case_id:nexus-rbac-developer
    场景: 验证开发人员的权限
        假定 集群已存在存储类
        并且 命名空间 "nexus-rbac-developer" 已存在
        并且 创建 "开发人员" ServiceAccount 和 Token
            """
            name: developer-sa
            namespace: nexus-rbac-developer
            role: developer
            """
        那么 "开发人员" 不应该能够创建 nexus 实例
            """
            instanceName: rbac-nexustest-developer
            namespace: nexus-rbac-developer
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """
        并且 创建 "平台管理员" ServiceAccount 和 Token
            """
            name: platform-admin-sa
            namespace: nexus-rbac-developer
            role: platform-admin
            """
        当 使用 "平台管理员" Token 创建 nexus 实例
            """
            instanceName: rbac-nexustest-developer
            namespace: nexus-rbac-developer
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """
        并且 "开发人员" 应该能够查看 nexus 实例
            """
            instanceName: rbac-nexustest-developer
            namespace: nexus-rbac-developer
            cluster: <config.acp.cluster>
            """
        并且 "开发人员" 不应该能够更新 nexus 实例
            """
            instanceName: rbac-nexustest-developer
            namespace: nexus-rbac-developer
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """

    @automated
    @priority-high
    @nexus-rbac-auditor
    @allure.label.case_id:nexus-rbac-auditor
    场景: 验证审计人员的权限
        假定 集群已存在存储类
        并且 命名空间 "nexus-rbac-auditor" 已存在
        并且 创建 "审计人员" ServiceAccount 和 Token
            """
            name: auditor-sa
            namespace: nexus-rbac-auditor
            role: auditor
            """
        那么 "审计人员" 不应该能够创建 nexus 实例
            """
            instanceName: rbac-nexustest-auditor
            namespace: nexus-rbac-auditor
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """
        并且 创建 "平台管理员" ServiceAccount 和 Token
            """
            name: platform-admin-sa
            namespace: nexus-rbac-auditor
            role: platform-admin
            """
        当 使用 "平台管理员" Token 创建 nexus 实例
            """
            instanceName: rbac-nexustest-auditor
            namespace: nexus-rbac-auditor
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """
        并且 "审计人员" 应该能够查看 nexus 实例
            """
            instanceName: rbac-nexustest-auditor
            namespace: nexus-rbac-auditor
            cluster: <config.acp.cluster>
            """
        并且 "审计人员" 不应该能够更新 nexus 实例
            """
            instanceName: rbac-nexustest-auditor
            namespace: nexus-rbac-auditor
            cluster: <config.acp.cluster>
            path: ./testdata/rbac-nexus.yaml
            """
