#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
chart_dir="${repo_root}/helm/bitnami-moodle"

helm dependency build "${chart_dir}"
helm lint --strict "${chart_dir}"
rendered="$(helm template moodle "${chart_dir}" \
  --namespace moodle \
  --set moodleHost=https://moodle.example.org \
  --set moodleReverseproxy=true \
  --set moodleSslproxy=true \
  --set externalDatabase.host=postgres.example.org \
  --set externalDatabase.database=moodle \
  --set externalDatabase.user=moodle \
  --set externalDatabase.existingSecret=moodle-db \
  --set mariadb.enabled=false)"

for expected in \
  'image: ghcr.io/reallyenglish-global/bitnami-moodle:5.3.1-debian-12-r0' \
  'name: MOODLE_DATABASE_TYPE' \
  'value: "pgsql"' \
  'name: MOODLE_DATABASE_PORT_NUMBER' \
  'value: "5432"' \
  'name: MOODLE_DATA_TO_PERSIST' \
  'value: config.php' \
  'name: MOODLE_HOST' \
  'value: "https://moodle.example.org"' \
  'name: MOODLE_REVERSEPROXY' \
  'name: MOODLE_SSLPROXY' \
  'type: Recreate'; do
  if [[ "${rendered}" != *"${expected}"* ]]; then
    printf 'Rendered chart is missing expected configuration: %s\n' "${expected}" >&2
    exit 1
  fi
done

printf 'Helm dependency build, strict lint, and rendered configuration assertions passed.\n'
