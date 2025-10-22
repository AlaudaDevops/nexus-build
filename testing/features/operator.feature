# language: zh-CN
@nexus-operator-feature
@e2e
功能: 通过 operator 部署 nexus，并验证业务功能

  @automated
  @priority-high
  @nexus-operator-deploy-basic
  @allure.label.case_id:nexus-operator-deploy-basic
  场景: 通过 operator 部署 nexus 基础实例
    假定 命名空间 "testing-nexus-operator-basic-<template.{{randAlphaNum 4 | toLower}}>" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    当 已导入 "nexus 实例" 资源: "./testdata/nexus-operator-basic.yaml"
    那么 "nexus-basic" 可以正常访问
      """
      url: http://admin:Nexus12345@<node.ip.random.readable>:<nodeport.http>/service/rest/v1/status/check
      timeout: 10m
      """
    并且 "nexus-basic" 实例资源检查通过
    并且 执行 "接受 EULA" 脚本成功
      | command |
      | ./hack/accepted-eula.sh http://<node.ip.random.readable>:<nodeport.http> admin Nexus12345 |
    并且 执行 "Nexus e2e" 脚本成功
      | command |
      | ./hack/run-e2e.sh http://<node.ip.random.readable>:<nodeport.http> admin Nexus12345 <template.{{ ternary "\"test_maven_repo.py test_pypi_repo.py\"" "" (eq .acp.protocolStack "IPv6") }}> |

