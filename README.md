# Bitnami-derived Moodle image and Helm chart

This public repository contains the Bitnami open-source build context for Moodle **5.3.1** (Debian 12 / PHP 8.4.27) and a ReallyEnglish-maintained Helm chart based on Bitnami's Moodle chart.

The source image is built from the upstream Bitnami Dockerfile, root filesystem scripts, and checksum manifest. `Dockerfile` pins the multi-architecture Bitnami Minideb base by OCI index digest; package downloads are SHA-256 checked during the image build. See [UPSTREAM.md](UPSTREAM.md) for pinned source commits and local changes. Preserve `LICENSE.md` and review component licenses in the generated image before redistributing it.

## Build the image

A single-platform local build (requires Docker Buildx and sufficient disk space; the Moodle artifact alone is over 100 MB):

```bash
docker buildx build \
  --platform linux/amd64 \
  --tag ghcr.io/reallyenglish-global/bitnami-moodle:5.3.1-debian-12-r0 \
  --load .
```

For an ARM64 image, use `--platform linux/arm64`. To publish a multi-platform manifest, authenticate to the chosen registry and use `--platform linux/amd64,linux/arm64 --push` instead of `--load`. This repository does not publish images automatically; the GHCR image referenced by the chart is not available until an authorized build-and-publish is performed. The Dockerfile's default Bitnami download endpoint is public; no download token is required.

## Helm chart

The chart is in `helm/bitnami-moodle`. It defaults to the ReallyEnglish image name and an external PostgreSQL database; the bundled MariaDB dependency is disabled by default. Before installing, build the pinned chart dependencies and supply site-specific values, including an existing database Secret whose `mariadb-password` key contains the database password:

```bash
helm dependency build helm/bitnami-moodle
helm lint helm/bitnami-moodle
helm template moodle helm/bitnami-moodle \
  --namespace moodle \
  --set moodleHost=https://moodle.example.org \
  --set externalDatabase.host=postgres.example.org \
  --set externalDatabase.database=moodle \
  --set externalDatabase.user=moodle \
  --set externalDatabase.existingSecret=moodle-db
```

Run `./scripts/verify-chart.sh` for a repeatable dependency-build, strict-lint, and rendered-values check.

Use a protected Secret manager workflow to create `moodle-db`; do not put passwords in a committed values file. Set `moodleReverseproxy` and `moodleSslproxy` to `true` when TLS is terminated at a reverse proxy. Configure `persistence` for the target storage class and backup policy.

The chart defaults `MOODLE_DATA_TO_PERSIST=config.php`: Moodle code comes from the image on each release, while configuration and Moodle data remain persistent. This is an intentional upgrade-safety improvement over persisting the entire application tree. **Do not apply it to an existing Moodle PVC or production release without a reviewed backup, migration, and rollback plan.** The chart and image have not been deployed to production.

## Current verification boundary

The repository was assembled from pinned Bitnami source trees. The initial Docker image has not been built or published, so the GHCR image reference is a planned location, not a currently pullable artifact. Run the build and Helm checks above before relying on it; no production configuration or workload is changed by this repository.
