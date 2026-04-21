#!/bin/bash
set -x

DIR="$(cd "$(dirname "$0")" && pwd)"
E2E_IMAGE="${E2E_IMAGE:-goharbor/harbor-e2e-engine:4.2.1-api}"
HARBOR_PASSWORD="${HARBOR_PASSWORD:-Harbor12345}"
HARBOR_HOST="${HARBOR_HOST:-}"
HARBOR_HOST_SCHEMA="${HARBOR_HOST_SCHEMA:-https}"
DOCKER_USER="${DOCKER_USER:-}"
DOCKER_PWD="${DOCKER_PWD:-}"

set +e

docker ps
# run db auth api cases
if [ "$1" = 'DB' ]; then
    docker run -i --privileged \
    -e HARBOR_PASSWORD="$HARBOR_PASSWORD" \
    -e HARBOR_HOST_SCHEMA="$HARBOR_HOST_SCHEMA" \
    -e HARBOR_HOST="$HARBOR_HOST" \
    -e COSIGN_EXPERIMENTAL=1 \
    -e CONTAINERD_ADDRESS=/var/run/docker/containerd/containerd.sock \
    -v $DIR/../../:/drone \
    -v $DIR/../:/ca \
    -v /var/log/harbor/:/var/log/harbor/ \
    -w /drone \
    "$E2E_IMAGE" \
    robot --exclude proxy_cache \
    -v DOCKER_USER:"${DOCKER_USER}" \
    -v DOCKER_PWD:"${DOCKER_PWD}" \
    -v ip:"${HARBOR_HOST}" -v ip1: \
    -v http_get_ca:false \
    -v protocol:http \
    -v HARBOR_PASSWORD:"$HARBOR_PASSWORD" \
    /drone/tests/robot-cases/Group1-Nightly/Setup.robot \
    /drone/tests/robot-cases/Group0-BAT/API_DB_SUCCESS.robot
elif [ "$1" = 'PROXY_CACHE' ]; then
    docker run -i --privileged -v $DIR/../../:/drone -v $DIR/../:/ca -w /drone $E2E_IMAGE robot --include setup  --include proxy_cache -v DOCKER_USER:${DOCKER_USER} -v DOCKER_PWD:${DOCKER_PWD} -v ip:$2  -v ip1: -v http_get_ca:false -v HARBOR_PASSWORD:Harbor12345 /drone/tests/robot-cases/Group1-Nightly/Setup.robot /drone/tests/robot-cases/Group0-BAT/API_DB.robot
elif [ "$1" = 'LDAP' ]; then
    # run ldap api cases
    python $DIR/../../tests/configharbor.py -H $IP -u $HARBOR_ADMIN -p $HARBOR_ADMIN_PASSWD -c auth_mode=ldap_auth \
                                  ldap_url=ldap://$IP \
                                  ldap_search_dn=cn=admin,dc=example,dc=com \
                                  ldap_search_password=admin \
                                  ldap_base_dn=dc=example,dc=com \
                                  ldap_uid=cn
    docker run -i --privileged -v $DIR/../../:/drone -v $DIR/../:/ca -w /drone $E2E_IMAGE robot -v DOCKER_USER:${DOCKER_USER} -v DOCKER_PWD:${DOCKER_PWD} -v ip:$2  -v ip1: -v http_get_ca:false -v HARBOR_PASSWORD:Harbor12345 /drone/tests/robot-cases/Group1-Nightly/Setup.robot /drone/tests/robot-cases/Group0-BAT/API_LDAP.robot
else
    rc=999
fi
rc=$?
## --------------------------------------------- Upload Harbor CI Logs -------------------------------------------
GIT_COMMIT=$(git rev-parse --short "$GITHUB_SHA")
outfile="integration-logs-$GIT_COMMIT.tar.gz"
tar -zcvf $outfile output.xml log.html

if [ $rc -gt 0 ]; then
    echo "Failed test count $rc" >&2
fi