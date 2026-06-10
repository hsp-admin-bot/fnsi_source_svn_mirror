#!/bin/bash
set -euo pipefail

DB_NAME="ntss"
USER="nkk"
PASS="nkk"
SRC_DIR="/root/mongo_pkg"
EXEC_DIR="/root/mongo_exec"

########################################
# Disk usage% check (warn only)
# - Always print current use%
# - WARN if: use% > 60 (do not exit)
########################################
check_usepct_or_warn() {
  max=70
  p=/

  echo -------------------------------------------------------
  echo "[INFO] Disk usage% check (df -h):"
  df -h
  echo -------------------------------------------------------

  u=$(df -P "$p" 2>/dev/null | awk 'END{gsub(/%/,"",$5);print $5}') || {
    echo "[ERROR] Disk check failed: $p" >&2
    exit 1
  }

  # limmit orver
  if [ "$u" -gt "$max" ]; then
    echo "*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*="
    echo "[WARN] Disk usage is high: $p (${u}% > ${max}%)" >&2
    echo "*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*="
  fi
  return 0
}

########################################
# add index
########################################
run_scripts() {
    shopt -s nullglob
    local src_files=("$SRC_DIR"/*.js)

    # 1件もなければ終了
    if [[ ${#src_files[@]} -eq 0 ]]; then
        echo "No .js files under ${SRC_DIR}. Nothing to do."
        return 0
    fi

    echo "==> 実行ディレクトリ初期化: ${EXEC_DIR}"
    rm -rf -- "$EXEC_DIR"
    mkdir -p -- "$EXEC_DIR"

    echo "==> スクリプトを実行ディレクトリへ移動: ${SRC_DIR} → ${EXEC_DIR}"
    mv -- "$SRC_DIR"/*.js "$EXEC_DIR"/

    # 実行ファイルをソートして列挙
    mapfile -t exec_files < <(printf "%s\n" "$EXEC_DIR"/*.js | sort)
    echo "==> 実行対象: ${#exec_files[@]} 件"

    for f in "${exec_files[@]}"; do
        local fname
        fname=$(basename "$f")
        echo "-------------------------------------------------------"
        echo "START  : ${fname}"

        if mongosh "$DB_NAME" --username "$USER" --password "$PASS" --file "$f"; then
            echo "SUCCESS: ${fname}"
        else
            echo "FAILED : ${fname}" >&2
            echo "Process stopped."
            exit 1
        fi
    done

    echo "All scripts executed successfully."
}

########################################
# main
########################################
check_usepct_or_warn
run_scripts
