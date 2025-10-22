# language: zh-CN

@allure.label.epic:nexus-chart-deploy
@nexus-chart-deploy-storage
功能: 支持多种存储类型部署 nexus

  @smoke
  @automated
  @priority-high
  @nexus-chart-deploy-storage-sc
  @allure.label.case_id:nexus-chart-deploy-storage-sc
  场景: 使用存储类方式部署 nexus
    假定 集群已存在存储类
    并且 命名空间 "testing-nexus-storage-sc-<template.{{randAlphaNum 4 | toLower}}>" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    当 使用 helm 部署实例到 "testing-nexus-storage-sc-<template.{{randAlphaNum 4 | toLower}}>" 命名空间
      """
      chartPath: ../
      releaseName: nexus-sc
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-storage-sc.yaml
      """
    并且 "nexus" 可以正常访问
      """
      url: http://admin:Nexus12345@<node.ip.random.readable>:<nodeport.http>/service/rest/v1/status/check
      timeout: 10m
      """
    并且 Pod 资源检查通过
      | name                 | path                                                                         | value                         |
      | nexus-sc-nxrm-ha-0   | $.spec.volumes[?(@.name == 'nexus-data')][0].persistentVolumeClaim.claimName | nexus-data-nexus-sc-nxrm-ha-0 |

  @automated
  @priority-high
  @nexus-chart-deploy-storage-hostpath
  @allure.label.case_id:nexus-chart-deploy-storage-hostpath
  场景: 使用 hostpath 方式部署 nexus
    假定 命名空间 "testing-nexus-storage-hostpath-<template.{{randAlphaNum 4 | toLower}}>" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    当 使用 helm 部署实例到 "testing-nexus-storage-hostpath-<template.{{randAlphaNum 4 | toLower}}>" 命名空间
      """
      chartPath: ../
      releaseName: nexus-hostpath
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-storage-hostpath.yaml
      """
    并且 "nexus" 可以正常访问
      """
      url: http://admin:Nexus12345@<node.ip.random.readable>:<nodeport.http>/service/rest/v1/status/check
      timeout: 10m
      """
    并且 Pod 资源检查通过
      | name                       | path            | value        |
      | nexus-hostpath-nxrm-ha-0   | $.spec.nodeName | <node.name.random> |
    并且 执行 "接受 EULA" 脚本成功
      | command |
      | ./hack/accepted-eula.sh http://<node.ip.random.readable>:<nodeport.http> admin Nexus12345 |
    并且 执行 "Nexus maven publish e2e" 脚本成功
      | command |
      | ./hack/run-e2e.sh http://<node.ip.random.readable>:<nodeport.http> admin Nexus12345 "test_maven_repo.py -k test_maven_publish" |

  @automated
  @priority-high
  @nexus-chart-deploy-storage-pvc
  @allure.label.case_id:nexus-chart-deploy-storage-pvc
  场景: 使用指定 pvc 的方式部署 nexus
    假定 命名空间 "testing-nexus-storage-pvc-<template.{{randAlphaNum 4 | toLower}}>" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    并且 已导入 "pvc" 资源: "./testdata/resources/storage-pvc.yaml"
    当 使用 helm 部署实例到 "testing-nexus-storage-pvc-<template.{{randAlphaNum 4 | toLower}}>" 命名空间
      """
      chartPath: ../
      releaseName: nexus-pvc
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-storage-pvc.yaml
      """
    并且 "nexus" 可以正常访问
      """
      url: http://admin:Nexus12345@<node.ip.random.readable>:<nodeport.http>/service/rest/v1/status/check
      timeout: 10m
      """
    并且 Pod 资源检查通过
      | name                  | path                                                                         | value       |
      | nexus-pvc-nxrm-ha-0   | $.spec.volumes[?(@.name == 'nexus-data')][0].persistentVolumeClaim.claimName | nexus-pvc   |
    并且 执行 "接受 EULA" 脚本成功
      | command |
      | ./hack/accepted-eula.sh http://<node.ip.random.readable>:<nodeport.http> admin Nexus12345 |
    并且 执行 "Nexus pypi e2e" 脚本成功
      | command |
      | ./hack/run-e2e.sh http://<node.ip.random.readable>:<nodeport.http> admin Nexus12345 test_pypi_repo.py |
