#!/usr/bin/env bash
set -euo pipefail

PSQL_PATH="${PSQL_PATH:-psql}"
PG_DUMP_PATH="${PG_DUMP_PATH:-pg_dump}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
ADMIN_DB="${ADMIN_DB:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-}"
COPY_ONLINE_SCHEMA="${COPY_ONLINE_SCHEMA:-false}"
SKIP_MONGO_INIT="${SKIP_MONGO_INIT:-false}"
MONGO_SHELL_PATH="${MONGO_SHELL_PATH:-mongosh}"
MONGO_HOST="${MONGO_HOST:-localhost}"
MONGO_PORT="${MONGO_PORT:-27017}"
MONGO_ADMIN_DB="${MONGO_ADMIN_DB:-admin}"
MONGO_ADMIN_USER="${MONGO_ADMIN_USER:-}"
MONGO_ADMIN_PASSWORD="${MONGO_ADMIN_PASSWORD:-}"
MONGO_DB_NAME="${MONGO_DB_NAME:-ntss}"
MONGO_APP_USER="${MONGO_APP_USER:-nkk}"
MONGO_APP_PASSWORD="${MONGO_APP_PASSWORD:-nkk}"
MONGO_RECREATE_DB="${MONGO_RECREATE_DB:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQL_FILE="${SCRIPT_DIR}/sql/init_all_databases.sql"
SCHEMA_COPY_SCRIPT="${SCRIPT_DIR}/initialize-transit-schema-from-online.sh"
MONGO_INIT_SCRIPT="${SCRIPT_DIR}/initialize-transit-mongo.sh"

if [[ ! -f "${SQL_FILE}" ]]; then
  echo "[init] SQL script not found: ${SQL_FILE}" >&2
  exit 1
fi

if [[ ! -f "${MONGO_INIT_SCRIPT}" ]]; then
  echo "[init] Mongo init script not found: ${MONGO_INIT_SCRIPT}" >&2
  exit 1
fi

if [[ ! -f "${SCHEMA_COPY_SCRIPT}" ]]; then
  echo "[init] Schema copy script not found: ${SCHEMA_COPY_SCRIPT}" >&2
  exit 1
fi

if [[ -n "${DB_PASSWORD}" ]]; then
  export PGPASSWORD="${DB_PASSWORD}"
fi

cleanup() {
  if [[ -n "${DB_PASSWORD}" ]]; then
    unset PGPASSWORD || true
  fi
}
trap cleanup EXIT

echo "[init] psql=${PSQL_PATH} host=${DB_HOST} port=${DB_PORT} user=${DB_USER} adminDb=${ADMIN_DB}"
echo "[init] target roles: convert_db=nkk, ntss_db4=nkk4, ntss_db5=nkk5, ntss_db6=nkk6"

"${PSQL_PATH}" \
  -h "${DB_HOST}" \
  -p "${DB_PORT}" \
  -U "${DB_USER}" \
  -d "${ADMIN_DB}" \
  -f "${SQL_FILE}"

case "${COPY_ONLINE_SCHEMA,,}" in
  1|true|yes|on)
    echo "[init] start transit schema copy from online"
    export PG_DUMP_PATH PSQL_PATH DB_HOST DB_PORT
    "${SCHEMA_COPY_SCRIPT}"
    ;;
  *)
    echo "[init] skip transit schema copy from online"
    ;;
esac

case "${SKIP_MONGO_INIT,,}" in
  1|true|yes|on)
    echo "[init] skip Mongo init"
    ;;
  *)
    echo "[init] start Mongo init"
    export MONGO_SHELL_PATH MONGO_HOST MONGO_PORT MONGO_ADMIN_DB
    export MONGO_ADMIN_USER MONGO_ADMIN_PASSWORD
    export MONGO_DB_NAME MONGO_APP_USER MONGO_APP_PASSWORD MONGO_RECREATE_DB
    "${MONGO_INIT_SCRIPT}"
    ;;
esac

echo "[init] complete: convert_db(V1/V2/V3), ntss_db4/5/6 initialized, mongo=${MONGO_DB_NAME}"
