# Harbor Tests

## Environment Variables

- `DEPENDS_IMAGE_REGISTRY`: The registry of the dependencies images, if not set, the default value is `ghcr.io`.
  During the execution process, the `goharbor/harbor-core:v2.8.2` and `goharbor/notary-server-photon:v2.2.0` images will be pulled from `DEPENDS_IMAGE_REGISTRY`.
- `HARBOR_HOST`: The host of the Harbor server that will be used to run the tests.
- `HARBOR_HOST_SCHEME`: The scheme of the Harbor server that will be used to run the tests, if not set, the default value is `https`.
- `HARBOR_PASSWORD`: The password of the Harbor admin user that will be used to run the tests.
- `CONTAINERD_ADDRESS`: The address of the containerd socket that will be used to run the tests, if not set, the default value is `/var/run/docker/containerd/containerd.sock`.

### Additional Environment Variables

you can set cosign related environment variables to run the tests, e.g.

- `COSIGN_EXPERIMENTAL`: If set to `1`, the experimental features of cosign will be enabled.
- `COSIGN_PRIVATE_INFRASTRUCTURE`: If set to `true`, the private infrastructure of cosign will be enabled.
- `COSIGN_TLOG_UPLOAD`: If set to `false`, the tlog upload of cosign will be disabled.