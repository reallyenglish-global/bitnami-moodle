# Upstream provenance and local changes

This repository derives its image and Helm resources from the following public Bitnami repositories:

- Container build source: [`bitnami/containers`](https://github.com/bitnami/containers), commit [`9bdcdf68d9d2a81942a9377ad97cb3caa1175011`](https://github.com/bitnami/containers/commit/9bdcdf68d9d2a81942a9377ad97cb3caa1175011), path `bitnami/moodle/5.3/debian-12/`. It supplies Moodle 5.3.1, PHP 8.4.27, Apache 2.4.71, package checksums, and the Bitnami setup scripts.
- Helm chart source: [`bitnami/charts`](https://github.com/bitnami/charts), commit [`2aac71a990b7e7c9a882bdce59855022894ac361`](https://github.com/bitnami/charts/commit/2aac71a990b7e7c9a882bdce59855022894ac361), path `bitnami/moodle/`.

The upstream `LICENSE.md` files identify Apache-2.0 and include Broadcom's copyright and third-party license notice; the original source notices and SPDX headers are retained. Components bundled into a built image carry their own licenses; consult `/opt/bitnami/licenses/licenses.txt` in the image and Bitnami's [open-source notices](https://bitnami.com/open-source) before redistribution.

## Local changes

- Pin the `bitnami/minideb:bookworm` multi-architecture OCI index by digest (`sha256:c4bd8d678760a38562cb33b7c490c8d1a2f4e36021e811a84f56528a0ff046d6`) and retarget OCI source/documentation labels to this repository.
- Use the public Bitnami download URL by default without a build secret; source package SHA-256 checks remain enabled.
- Set the chart identity/version to `bitnami-moodle` / `0.1.0` and Moodle app version to `5.3.1`; configure the chart's default image reference for the planned ReallyEnglish GHCR package.
- Default the chart to external PostgreSQL (`pgsql`, port 5432), disable bundled MariaDB, disallow empty passwords, and use a recreate strategy for its single RWO volume.
- Persist only `config.php`, not the Moodle code tree, so image upgrades use the code from the new image. Add chart values for canonical host and reverse-proxy/TLS-termination settings and pass them to the container.

No image has been pushed, and no GHCR or Artifact Registry credentials are stored in this repository.
