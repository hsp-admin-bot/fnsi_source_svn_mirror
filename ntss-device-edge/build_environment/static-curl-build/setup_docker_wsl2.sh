#!/bin/bash
# ============================================================
# setup_docker_wsl2.sh
# WSL2 (Ubuntu) に Docker Engine を導入するセットアップスクリプト
# Docker Desktop 不要・商用利用可能
# ============================================================
set -euo pipefail

echo "============================================"
echo " WSL2 Docker Engine セットアップ"
echo "============================================"
echo ""

# ------------------------------------------------------------
# 0. WSL2 かどうか確認
# ------------------------------------------------------------
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    echo "[WARN] WSL2 環境ではない可能性があります。続行しますか？ (y/N)"
    read -r ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 1
fi

# ------------------------------------------------------------
# 1. systemd の有効化確認
#    Ubuntu 22.04 以降の WSL2 では systemd が使える
# ------------------------------------------------------------
echo "[STEP 1] systemd の確認..."

if [ "$(ps -p 1 -o comm=)" != "systemd" ]; then
    echo ""
    echo "[ACTION REQUIRED] systemd が有効になっていません。"
    echo "  以下の内容を /etc/wsl.conf に追記してください:"
    echo ""
    echo "  ┌─────────────────────────────┐"
    echo "  │ [boot]                       │"
    echo "  │ systemd=true                 │"
    echo "  └─────────────────────────────┘"
    echo ""
    echo "  追記後、PowerShell で以下を実行して WSL2 を再起動してください:"
    echo "    wsl --shutdown"
    echo "    # その後 WSL2 を再度開く"
    echo ""
    echo "  再起動後にこのスクリプトを再実行してください。"
    exit 1
fi
echo "[OK] systemd が有効です。"

# ------------------------------------------------------------
# 2. Docker Engine のインストール
# ------------------------------------------------------------
echo ""
echo "[STEP 2] Docker Engine をインストールします..."

if command -v docker &>/dev/null; then
    echo "[SKIP] Docker は既にインストールされています: $(docker --version)"
else
    # 公式インストールスクリプトを使用
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    rm /tmp/get-docker.sh
    echo "[OK] Docker Engine をインストールしました。"
fi

# ------------------------------------------------------------
# 3. 現在のユーザーを docker グループに追加
# ------------------------------------------------------------
echo ""
echo "[STEP 3] ユーザーを docker グループに追加します..."

if groups "$USER" | grep -q docker; then
    echo "[SKIP] 既に docker グループに所属しています。"
else
    sudo usermod -aG docker "$USER"
    echo "[OK] docker グループに追加しました。"
    echo "[NOTE] グループ変更を反映するために、いったんシェルを再起動してください:"
    echo "       exec newgrp docker"
fi

# ------------------------------------------------------------
# 4. Docker サービスの起動確認
# ------------------------------------------------------------
echo ""
echo "[STEP 4] Docker サービスを起動します..."
sudo systemctl enable docker --quiet
sudo systemctl start docker
echo "[OK] Docker サービスが起動しています。"

# ------------------------------------------------------------
# 5. QEMU + binfmt のインストール（ARM エミュレーション用）
# ------------------------------------------------------------
echo ""
echo "[STEP 5] QEMU（ARM エミュレーター）をインストールします..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
    qemu-user-static \
    binfmt-support

# binfmt に ARM を登録
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
echo "[OK] QEMU ARM エミュレーターを登録しました。"

# ------------------------------------------------------------
# 6. Docker Buildx の設定（マルチプラットフォームビルド用）
# ------------------------------------------------------------
echo ""
echo "[STEP 6] Docker Buildx を設定します..."

# buildx が利用可能か確認（Docker 23.0 以降は標準搭載）
if ! docker buildx version &>/dev/null; then
    echo "[ERROR] Docker Buildx が利用できません。Docker を最新版に更新してください。"
    exit 1
fi

# arm/v7 対応のビルダーを作成
if docker buildx ls | grep -q "armhf-builder"; then
    echo "[SKIP] armhf-builder は既に存在します。"
else
    docker buildx create \
        --name armhf-builder \
        --driver docker-container \
        --platform linux/arm/v7,linux/amd64 \
        --use
    docker buildx inspect --bootstrap
    echo "[OK] armhf-builder を作成しました。"
fi

# ------------------------------------------------------------
# 7. 動作確認
# ------------------------------------------------------------
echo ""
echo "[STEP 7] ARM エミュレーションの動作確認..."
if docker run --rm --platform linux/arm/v7 arm32v7/ubuntu:24.04 \
    uname -m 2>/dev/null | grep -q armv7; then
    echo "[OK] ARM (armv7) エミュレーションが正常に動作しています。"
else
    echo "[WARN] 動作確認に失敗しました。ステップ 5 の QEMU 登録を再実行してください:"
    echo "       docker run --rm --privileged multiarch/qemu-user-static --reset -p yes"
fi

# ------------------------------------------------------------
# 完了
# ------------------------------------------------------------
echo ""
echo "============================================"
echo " セットアップ完了！"
echo " 次のステップ: build.sh を実行してください"
echo "============================================"

