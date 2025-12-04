#!/bin/bash
set -ex

# Harbor E2E 测试脚本
# 用法: ./run-harbor-e2e.sh [HARBOR_HOST_SCHEMA] [HARBOR_HOST] [HARBOR_PASSWORD] [PODMAN_OPTS]

#
# 例如:
# 1. 基本用法: ./run-harbor-e2e.sh http 127.0.0.1  Harbor12345
# 2. 附加 Podman 选项: ./run-harbor-e2e.sh http 127.0.0.1 Harbor12345 test --network host
# 3. 附加环境变量:
#   - E2E_ENGINE_IMAGE: 指定测试引擎镜像
#   - E2E_DEPENDS_IMAGE_REGISTRY: 指定依赖镜像仓库, 默认值为 `ghcr.io`.
#     在离线环境中执行时，需要在目标镜像仓库上准备 `goharbor/harbor-core:v2.8.2` 镜像.
#   - E2E_INCLUDE_TAGS: 指定要包含的测试标签, e.g. "setup OR cosign"

if [ "${RUN_E2E_TEST}" != "true" ]; then
    echo "Skipping Harbor e2e test"
    exit 0
fi

# 判断IP地址是否为IPv6格式
is_ipv6() {
    if [[ "$1" == \[*\]* ]]; then
        return 0  # 是IPv6
    else
        return 1  # 不是IPv6
    fi
}

# 该镜像的默认值会由 `.tekton/all-in-one.yaml` 流水线中的 `update-image-tags` 自动更新
# 如需修改，请同步更新 Makefile 中的 `update-e2e-image-tag`
TEST_IMAGE=${E2E_ENGINE_IMAGE:-"registry.alauda.cn:60070/devops/harbor-e2e-engine:2.12.4-g1b0dbf8"}
DEPENDS_IMAGE_REGISTRY=${E2E_DEPENDS_IMAGE_REGISTRY:-"ghcr.io"}

HARBOR_HOST_SCHEMA=${1:-"http"}
HARBOR_HOST=${2:-"127.0.0.1"}
HARBOR_PASSWORD=${3:-"Harbor12345"}
INSTANCE_NAME=${4:-"harbor"}

PODMAN_OPTS=""
if [ $# -ge 4 ]; then
    shift 4
    PODMAN_OPTS="$@"
fi

if [ -z "$RESULT_DIR" ]; then
   RESULT_DIR="./results"
fi

OUTPUT_DIR="$RESULT_DIR/$INSTANCE_NAME"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR=$(realpath "${OUTPUT_DIR}")


EXCLUDE_TAGS_ARRAY=()
case "${TEST_SUITE}" in
    "daily")
        EXCLUDE_TAGS_ARRAY=("proxy_cache" "gc" "replic_rule" "referrers" "retain_image_last_pull_time" "robot_account" "scan_all" "job_service_dashboard" "security_hub" "tag_immutability" "tag_retention" "scan_data_export")
        ;;
    "full")
        EXCLUDE_TAGS_ARRAY=("proxy_cache")
        ;;
    "custom")
        if [ -n "${EXCLUDE_TAGS}" ]; then
            read -ra EXCLUDE_TAGS_ARRAY <<< "${EXCLUDE_TAGS}"
        else
            EXCLUDE_TAGS_ARRAY=("proxy_cache" "replic_rule")
        fi
        ;;
    *)
        echo "Using daily suite as default"
        EXCLUDE_TAGS_ARRAY=("proxy_cache" "replic_rule")
        ;;
esac

# 检查HARBOR_HOST是否为IPv6地址，如果是则添加podman_pull_push到排除标签
if is_ipv6 "${HARBOR_HOST}"; then
    echo "Detected IPv6 address, adding podman_pull_push to exclude tags"
    EXCLUDE_TAGS_ARRAY+=("podman_pull_push")
fi

EXCLUDE_TAGS=""
if [ ${#EXCLUDE_TAGS_ARRAY[@]} -gt 0 ]; then
    EXCLUDE_TAGS=$(printf "%sOR" "${EXCLUDE_TAGS_ARRAY[@]}" | sed 's/OR$//')
fi

INCLUDE_TAGS=${E2E_INCLUDE_TAGS:-""}

echo "Run Harbor e2e..."
echo "Harbor password: ${HARBOR_PASSWORD}"
echo "Harbor host: ${HARBOR_HOST}"
echo "Harbor scheme: ${HARBOR_HOST_SCHEMA}"
echo "Podman options: ${PODMAN_OPTS}"
echo "Exclude tags: ${EXCLUDE_TAGS}"
echo "Output ${OUTPUT_DIR}"

mkdir -p /var/log/harbor

podman network create --subnet 2001:db8:1::/64 --ipv6 harbor

podman run ${PODMAN_OPTS} -i --privileged --network=harbor \
  -e HARBOR_PASSWORD="${HARBOR_PASSWORD}" \
  -e HARBOR_HOST_SCHEMA="${HARBOR_HOST_SCHEMA}" \
  -e HARBOR_HOST="${HARBOR_HOST}" \
  -e DEPENDS_IMAGE_REGISTRY="${DEPENDS_IMAGE_REGISTRY}" \
  -e COSIGN_EXPERIMENTAL=1 \
  -e COSIGN_TLOG_UPLOAD=false \
  -e COSIGN_PRIVATE_INFRASTRUCTURE=true \
  -v /var/log/harbor/:/var/log/harbor/ \
  -v "${OUTPUT_DIR}:/results" \
  -w /drone \
  "${TEST_IMAGE}" \
  robot --exclude "${EXCLUDE_TAGS}" --include "${INCLUDE_TAGS}" \
  -v ip:"${HARBOR_HOST}" -v ip1: \
  -v http_get_ca:false \
  -v protocol:"${HARBOR_HOST_SCHEMA}" \
  -v HARBOR_PASSWORD:"${HARBOR_PASSWORD}" \
  -v DOCKER_USER:"${DOCKER_USER}" \
  -v DOCKER_PWD:"${DOCKER_PWD}" \
  -d /results \
  /drone/tests/robot-cases/Group1-Nightly/Setup.robot \
  /drone/tests/robot-cases/Group0-BAT/API_DB_SUCCESS.robot

if [ $? -eq 0 ]; then
    echo "Harbor e2e done: passed";
    exit 0
else
    echo "Harbor e2e done: failed";
    exit 1
fi
