#!/usr/bin/env bash
set -euo pipefail

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
MONGO_JS="${SCRIPT_DIR}/mongo/init_ntss.js"

if [[ ! -f "${MONGO_JS}" ]]; then
  echo "[init][mongo] JS script not found: ${MONGO_JS}" >&2
  exit 1
fi

if [[ -n "${MONGO_ADMIN_USER}" && -z "${MONGO_ADMIN_PASSWORD}" ]]; then
  echo "[init][mongo] MONGO_ADMIN_USER is set but MONGO_ADMIN_PASSWORD is empty" >&2
  exit 1
fi

if [[ -z "${MONGO_ADMIN_USER}" && -n "${MONGO_ADMIN_PASSWORD}" ]]; then
  echo "[init][mongo] MONGO_ADMIN_PASSWORD is set but MONGO_ADMIN_USER is empty" >&2
  exit 1
fi

cmd=(
  "${MONGO_SHELL_PATH}"
  --quiet
  --host "${MONGO_HOST}"
  --port "${MONGO_PORT}"
)

if [[ -n "${MONGO_ADMIN_USER}" ]]; then
  cmd+=(--username "${MONGO_ADMIN_USER}")
  cmd+=(--password "${MONGO_ADMIN_PASSWORD}")
  cmd+=(--authenticationDatabase "${MONGO_ADMIN_DB}")
fi

cmd+=(--file "${MONGO_JS}")

echo "[init][mongo] shell=${MONGO_SHELL_PATH} host=${MONGO_HOST} port=${MONGO_PORT} authDb=${MONGO_ADMIN_DB}"
echo "[init][mongo] target db=${MONGO_DB_NAME} appUser=${MONGO_APP_USER} recreateDb=${MONGO_RECREATE_DB}"

"${cmd[@]}"

echo "[init][mongo] complete: ${MONGO_DB_NAME}"
