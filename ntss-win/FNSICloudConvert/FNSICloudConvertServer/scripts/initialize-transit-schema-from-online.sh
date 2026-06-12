#!/usr/bin/env bash
set -euo pipefail

PG_DUMP_PATH="${PG_DUMP_PATH:-pg_dump}"
PSQL_PATH="${PSQL_PATH:-psql}"

ONLINE_DB_HOST="${ONLINE_DB_HOST:-uat-fnsi-db-real-0324-cluster.cluster-cnr7cvlcb4ym.ap-northeast-1.rds.amazonaws.com}"
ONLINE_DB_PORT="${ONLINE_DB_PORT:-5432}"

ONLINE_DB4_HOST="${ONLINE_DB4_HOST:-${ONLINE_DB_HOST}}"
ONLINE_DB4_PORT="${ONLINE_DB4_PORT:-${ONLINE_DB_PORT}}"
ONLINE_DB4_NAME="${ONLINE_DB4_NAME:-ntss_db4}"
ONLINE_DB4_USER="${ONLINE_DB4_USER:-nkk4}"
ONLINE_DB4_PASSWORD="${ONLINE_DB4_PASSWORD:-nkk4}"

ONLINE_DB5_HOST="${ONLINE_DB5_HOST:-${ONLINE_DB_HOST}}"
ONLINE_DB5_PORT="${ONLINE_DB5_PORT:-${ONLINE_DB_PORT}}"
ONLINE_DB5_NAME="${ONLINE_DB5_NAME:-ntss_db5}"
ONLINE_DB5_USER="${ONLINE_DB5_USER:-nkk5}"
ONLINE_DB5_PASSWORD="${ONLINE_DB5_PASSWORD:-nkk5}"

ONLINE_DB6_HOST="${ONLINE_DB6_HOST:-${ONLINE_DB_HOST}}"
ONLINE_DB6_PORT="${ONLINE_DB6_PORT:-${ONLINE_DB_PORT}}"
ONLINE_DB6_NAME="${ONLINE_DB6_NAME:-ntss_db6}"
ONLINE_DB6_USER="${ONLINE_DB6_USER:-nkk6}"
ONLINE_DB6_PASSWORD="${ONLINE_DB6_PASSWORD:-nkk6}"

TRANSIT_DB_HOST="${TRANSIT_DB_HOST:-${DB_HOST:-localhost}}"
TRANSIT_DB_PORT="${TRANSIT_DB_PORT:-${DB_PORT:-5432}}"

TRANSIT_DB4_NAME="${TRANSIT_DB4_NAME:-ntss_db4}"
TRANSIT_DB4_USER="${TRANSIT_DB4_USER:-nkk4}"
TRANSIT_DB4_PASSWORD="${TRANSIT_DB4_PASSWORD:-nkk4}"

TRANSIT_DB5_NAME="${TRANSIT_DB5_NAME:-ntss_db5}"
TRANSIT_DB5_USER="${TRANSIT_DB5_USER:-nkk5}"
TRANSIT_DB5_PASSWORD="${TRANSIT_DB5_PASSWORD:-nkk5}"

TRANSIT_DB6_NAME="${TRANSIT_DB6_NAME:-ntss_db6}"
TRANSIT_DB6_USER="${TRANSIT_DB6_USER:-nkk6}"
TRANSIT_DB6_PASSWORD="${TRANSIT_DB6_PASSWORD:-nkk6}"

if [[ -z "${ONLINE_DB_HOST}" && -z "${ONLINE_DB4_HOST}" && -z "${ONLINE_DB5_HOST}" && -z "${ONLINE_DB6_HOST}" ]]; then
  echo "[init][schema] ONLINE_DB_HOST (or ONLINE_DB4_HOST/5_HOST/6_HOST) is required" >&2
  exit 1
fi

TMP_FILES=()

cleanup() {
  local file
  for file in "${TMP_FILES[@]:-}"; do
    rm -f "${file}" 2>/dev/null || true
  done
}
trap cleanup EXIT

dump_schema() {
  local src_host="$1"
  local src_port="$2"
  local src_db="$3"
  local src_user="$4"
  local src_password="$5"
  local label="$6"
  local dump_file

  dump_file="$(mktemp "/tmp/${label}_schema_XXXXXX.sql")"
  TMP_FILES+=("${dump_file}")

  echo "[init][schema] dump schema: ${label} ${src_user}@${src_host}:${src_port}/${src_db}" >&2
  PGPASSWORD="${src_password}" "${PG_DUMP_PATH}" \
    -h "${src_host}" \
    -p "${src_port}" \
    -U "${src_user}" \
    -d "${src_db}" \
    --schema=ntss \
    --schema-only \
    --no-owner \
    --no-privileges \
    --quote-all-identifiers \
    -f "${dump_file}"

  printf '%s\n' "${dump_file}"
}

apply_schema() {
  local dump_file="$1"
  local dst_host="$2"
  local dst_port="$3"
  local dst_db="$4"
  local dst_user="$5"
  local dst_password="$6"
  local label="$7"

  echo "[init][schema] reset transit schema: ${label} ${dst_user}@${dst_host}:${dst_port}/${dst_db}"
  PGPASSWORD="${dst_password}" "${PSQL_PATH}" \
    -h "${dst_host}" \
    -p "${dst_port}" \
    -U "${dst_user}" \
    -d "${dst_db}" \
    -v ON_ERROR_STOP=1 \
    -c 'DROP SCHEMA IF EXISTS ntss CASCADE;'

  echo "[init][schema] apply schema: ${label} ${dst_user}@${dst_host}:${dst_port}/${dst_db}"
  PGPASSWORD="${dst_password}" "${PSQL_PATH}" \
    -h "${dst_host}" \
    -p "${dst_port}" \
    -U "${dst_user}" \
    -d "${dst_db}" \
    -v ON_ERROR_STOP=1 \
    -f "${dump_file}"
}

copy_one() {
  local src_host="$1"
  local src_port="$2"
  local src_db="$3"
  local src_user="$4"
  local src_password="$5"
  local dst_db="$6"
  local dst_user="$7"
  local dst_password="$8"
  local label="$9"
  local dump_file

  dump_file="$(dump_schema "${src_host}" "${src_port}" "${src_db}" "${src_user}" "${src_password}" "${label}")"
  apply_schema "${dump_file}" "${TRANSIT_DB_HOST}" "${TRANSIT_DB_PORT}" "${dst_db}" "${dst_user}" "${dst_password}" "${label}"
  echo "[init][schema] complete: ${label}"
}

echo "[init][schema] source online dbs -> local transit dbs"
echo "[init][schema] transit target host=${TRANSIT_DB_HOST} port=${TRANSIT_DB_PORT}"

copy_one "${ONLINE_DB4_HOST}" "${ONLINE_DB4_PORT}" "${ONLINE_DB4_NAME}" "${ONLINE_DB4_USER}" "${ONLINE_DB4_PASSWORD}" \
         "${TRANSIT_DB4_NAME}" "${TRANSIT_DB4_USER}" "${TRANSIT_DB4_PASSWORD}" \
         "db4"

copy_one "${ONLINE_DB5_HOST}" "${ONLINE_DB5_PORT}" "${ONLINE_DB5_NAME}" "${ONLINE_DB5_USER}" "${ONLINE_DB5_PASSWORD}" \
         "${TRANSIT_DB5_NAME}" "${TRANSIT_DB5_USER}" "${TRANSIT_DB5_PASSWORD}" \
         "db5"

copy_one "${ONLINE_DB6_HOST}" "${ONLINE_DB6_PORT}" "${ONLINE_DB6_NAME}" "${ONLINE_DB6_USER}" "${ONLINE_DB6_PASSWORD}" \
         "${TRANSIT_DB6_NAME}" "${TRANSIT_DB6_USER}" "${TRANSIT_DB6_PASSWORD}" \
         "db6"

echo "[init][schema] all transit schemas copied from online"
