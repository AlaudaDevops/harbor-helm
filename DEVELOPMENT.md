# harbor-helm 开发指南

## 仓库结构

```
harbor-helm/
├── .tekton/
│   ├── all-in-one.yaml                # 构建 harbor 组件镜像、e2e 镜像、commit 镜像版本、触发 integration-test 流水线
│   ├── integration-test.yaml          # 执行集成测试 `make test-smoke`，包含运行社区 e2e 测试
│   └── pipeline/
│       └── dind-integration-test.yaml # 集成测试 Pipeline
├── subtree/                           # 通过 git subtree 引用的目录
│   └── harbor/                        # 引用 `https://github.com/goharbor/harbor`
│       ├── make/                      # harbor 组件构建
│       ├── src/                       # harbor 组件源代码
│       └── tests/                     # harbor 社区 e2e 测试
├── testing/                           # 集成测试的根目录
├── DEVELOPMENT.md                     # 本文档
└── README.md                          # README.md 保留 fork 前的内容
```

## all-in-one 流水线

### 功能

- 构建 harbor 组件镜像
- 构建 e2e 镜像
- commit 新镜像到当前分支，更新以下文件：
    - testing/testdata/script/run-harbor-e2e.sh
    - testing/testdata/snippets/base-values.yaml
    - values.yaml
- 触发 integration-test 流水线，基于 [PAC Incoming Webhook](https://pipelinesascode.com/docs/guide/incoming_webhook/)

### 机制

harbor 的组件主要分为以下几类：

- 核心组件，构建前需要先执行 `make compile`
    - harbor-core
    - harbor-jobservice
    - harbor-registryctl
- 依赖第三方功能的组件，构建前需要先拉取第三方依赖
    - trivy-adapter-photon
    - registry-photon
- 无前置依赖的组件，可以直接构建
    - harbor-portal
    - harbor-exporter
    - nginx-photon
- 仅用于集成测试的组件
    - harbor-db
    - redis-photon

[all-in-one 流水线](.tekton/all-in-one.yaml) 中根据这些组件的特点，分别设置了不同的前置 Task（`compile`、`fetch-thirdparty` 等）。

并且镜像构建使用了 `reuse-artifact` 的特性，如果相同 tag 的组件镜像已经构建成功了，则不会重复构建，避免被运维的 412 策略 block 导致流水线执行失败。

## e2e 镜像

e2e 镜像也是在 [all-in-one 流水线](.tekton/all-in-one.yaml) 中构建的，构建成功后会自动更新 [e2e 脚本](testing/testdata/script/run-harbor-e2e.sh) 中的镜像 tag。

执行 [e2e 脚本](testing/testdata/script/run-harbor-e2e.sh) 需要 docker 环境，所以无法直接使用 edge-devops-task 中的 `vcluster-integration-test`。

新增了一条基于 `docker-in-docker` 的[集成测试流水线](.tekton/pipeline/dind-integration-test.yaml)，与 `vcluster-integration-test` 区别主要在于：

- run-test 是基于 `docker-in-docker` Task 运行的
- upload-allure-report 支持 pre-upload-script 参数，用于上传 harbor 脚本

e2e 日志会输出在 `harbor-e2e-reports` 目录并上传到 minio，可以通过 pipeline result 中的 url 访问。

## 集成测试

[all-in-one 流水线](.tekton/all-in-one.yaml) 的所有步骤完成后，会自动触发 [integration-test 流水线](.tekton/integration-test.yaml)。

只有当 harbor 源码被修改时，才会执行 e2e 测试（通过传递 `source_code_changed` 参数）。

直接通过评论触发 [integration-test 流水线](.tekton/integration-test.yaml) 时，默认会执行 e2e 测试。可以通过 `skip-e2e` 来跳过 e2e 测试。

## 升级 harbor 版本

```shell
git subtree pull --prefix=subtree/harbor https://github.com/goharbor/harbor.git <tag>
```

执行 `git subtree pull` 后，会自动将远程仓库的 tag 合并到指定目录，加上 `--squash` 参数可以合并 commit，处理完 conflict 后 push 即可。
