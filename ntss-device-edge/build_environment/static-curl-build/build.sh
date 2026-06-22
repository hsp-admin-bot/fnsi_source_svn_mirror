#!/bin/bash
# ============================================================
# build.sh  ―  静的リンク curl (armhf / OpenSSL 3.5) ビルドスクリプト
# ターゲット: TI Sitara AM3352 (ARM Cortex-A8)  ※ MA-E300 シリーズ
# 動作環境: WSL2 上の Docker Engine（Docker Desktop 不要）
# プロキシ対応版
# ============================================================
set -euo pipefail

# ============================================================
# ★ プロキシ設定（プロキシが不要な場合は空文字のままにする）
# ============================================================
HTTP_PROXY=""     # 例: "http://proxy.example.com:8080"
HTTPS_PROXY=""    # 例: "http://proxy.example.com:8080"
NO_PROXY="localhost,127.0.0.1,192.168.0.0/12"       # 例: "localhost,127.0.0.1,192.168.0.0/16"
# ============================================================

# ---------- その他設定 ----------
OUTPUT_DIR="./output"
IMAGE_TAG="static-curl-armhf:latest"
OPENSSL_VER="3.5.7"
CURL_VER="8.20.0"
# --------------------------------

echo "============================================"
echo " static curl ビルダー (armhf + OpenSSL 3.5)"
echo " ターゲット: ARM Cortex-A8 / MA-E300"
echo "============================================"

# 1. Docker が起動しているか確認
if ! docker info > /dev/null 2>&1; then
    echo "[ERROR] Docker が起動していません。"
    echo "  以下のコマンドで Docker サービスを起動してください:"
    echo "    sudo systemctl start docker"
    exit 1
fi

# 2. プロキシ設定の確認と表示
#    （スクリプト内未設定でも環境変数から自動取得する）
RESOLVED_HTTP_PROXY="${HTTP_PROXY:-${http_proxy:-}}"
RESOLVED_HTTPS_PROXY="${HTTPS_PROXY:-${https_proxy:-}}"
RESOLVED_NO_PROXY="${NO_PROXY:-${no_proxy:-}}"

if [ -n "${RESOLVED_HTTP_PROXY}" ] || [ -n "${RESOLVED_HTTPS_PROXY}" ]; then
    echo "[INFO] プロキシ設定を検出しました:"
    [ -n "${RESOLVED_HTTP_PROXY}" ]  && echo "       HTTP_PROXY  = ${RESOLVED_HTTP_PROXY}"
    [ -n "${RESOLVED_HTTPS_PROXY}" ] && echo "       HTTPS_PROXY = ${RESOLVED_HTTPS_PROXY}"
    [ -n "${RESOLVED_NO_PROXY}" ]    && echo "       NO_PROXY    = ${RESOLVED_NO_PROXY}"
else
    echo "[INFO] プロキシ設定なし（直接接続）"
fi
echo ""

# 3. QEMU (multi-platform) のサポート確認・有効化
echo "[INFO] QEMU エミュレーター (ARM サポート) を確認・登録します..."
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes > /dev/null 2>&1 || true

# 4. BuildKit で armhf イメージをビルド
#    --build-arg でプロキシをコンテナ内（wget 等）に渡す
echo "[INFO] Docker ビルドを開始します..."
echo "       OpenSSL: ${OPENSSL_VER}  /  curl: ${CURL_VER}"
echo ""

# プロキシ引数を動的に組み立て（未設定の場合は引数自体を渡さない）
PROXY_ARGS=()
[ -n "${RESOLVED_HTTP_PROXY}" ]  && PROXY_ARGS+=(--build-arg "http_proxy=${RESOLVED_HTTP_PROXY}")
[ -n "${RESOLVED_HTTP_PROXY}" ]  && PROXY_ARGS+=(--build-arg "HTTP_PROXY=${RESOLVED_HTTP_PROXY}")
[ -n "${RESOLVED_HTTPS_PROXY}" ] && PROXY_ARGS+=(--build-arg "https_proxy=${RESOLVED_HTTPS_PROXY}")
[ -n "${RESOLVED_HTTPS_PROXY}" ] && PROXY_ARGS+=(--build-arg "HTTPS_PROXY=${RESOLVED_HTTPS_PROXY}")
[ -n "${RESOLVED_NO_PROXY}" ]    && PROXY_ARGS+=(--build-arg "no_proxy=${RESOLVED_NO_PROXY}")
[ -n "${RESOLVED_NO_PROXY}" ]    && PROXY_ARGS+=(--build-arg "NO_PROXY=${RESOLVED_NO_PROXY}")

DOCKER_BUILDKIT=1 docker build \
    --platform linux/arm/v7 \
    --build-arg OPENSSL_VERSION="${OPENSSL_VER}" \
    --build-arg CURL_VERSION="${CURL_VER}" \
    "${PROXY_ARGS[@]}" \
    -t "${IMAGE_TAG}" \
    .

# 5. バイナリをコンテナから取り出す
mkdir -p "${OUTPUT_DIR}"
echo ""
echo "[INFO] バイナリを ${OUTPUT_DIR}/curl に抽出します..."

CID=$(docker create --platform linux/arm/v7 "${IMAGE_TAG}")
docker cp "${CID}:/opt/curl/bin/curl" "${OUTPUT_DIR}/curl"
docker rm "${CID}" > /dev/null

# 6. 確認
echo ""
echo "[OK] ビルド完了！"
echo ""
echo "--- ファイル情報 ---"
ls -lh "${OUTPUT_DIR}/curl"
file  "${OUTPUT_DIR}/curl"
echo "期待される出力: ELF 32-bit LSB executable, ARM, EABI5 ... statically linked"
echo ""
echo "--- curl バージョン (QEMU経由で実行) ---"
docker run --rm --platform linux/arm/v7 "${IMAGE_TAG}" /opt/curl/bin/curl --version 2>/dev/null || \
    echo "(バージョン確認はターゲット機器上で実行してください)"
echo ""
echo "--- デプロイ手順 ---"
echo "  scp ${OUTPUT_DIR}/curl ユーザー名@デバイスIP:/usr/local/bin/curl"
echo "  ssh ユーザー名@デバイスIP 'chmod +x /usr/local/bin/curl && curl --version'"
