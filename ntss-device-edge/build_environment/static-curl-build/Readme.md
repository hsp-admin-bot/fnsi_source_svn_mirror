# static-curl-armhf ビルド手順

OpenSSL 3.5 + curl を静的リンクした **armhf (ARM Cortex-A8 / ARMv7-A)** バイナリを  
**Windows の WSL2 + Docker Engine** 環境でビルドするための一式です。

対象ハードウェア: **FutureNet MA-E300 シリーズ**  
(CPU: TI Sitara AM3352 / ARM Cortex-A8)

---

## ファイル構成

```
./
├── Dockerfile              … ビルド定義（OpenSSL 3.5 → curl の順でビルド）
├── build.sh                … ビルド実行スクリプト
├── setup_docker_wsl2.sh    … Docker Engine セットアップスクリプト
└── README.md               … このファイル
```

---

## 前提条件

| 必要なもの | 確認コマンド | 備考 |
|---|---|---|
| Windows 10/11 (WSL2 対応) | `wsl --version` | |
| WSL2 ディストリビューション | `wsl -l -v` | Ubuntu 22.04 以上を推奨 |

> **Docker Desktop は不要です。**  
> Docker Engine（OSSのCLI＋デーモン本体）を WSL2 内に直接インストールします。  
> Docker Engine は Apache 2.0 ライセンスであり、商用利用に制限はありません。

---

## セットアップ手順

### 手順1: ファイルを WSL2 内に配置

WSL2 のターミナルを開き、作業ディレクトリを作成します。

```bash
mkdir ~/static-curl-build
cd ~/static-curl-build
# 全ファイルをこのディレクトリに置く
```

> **注意**: Windows の `/mnt/c/...` パス上では動作が著しく遅くなります。  
> WSL2 ネイティブのホームディレクトリ (`~/`) 以下で作業してください。

---

### 手順2: プロキシの設定（プロキシ環境の場合のみ）

プロキシ環境下では、セットアップ前に以下の設定を済ませてください。

#### (a) WSL2 の環境変数

`~/.bashrc` に以下を追記します。

```bash
export http_proxy="http://proxy.example.com:8080"
export https_proxy="http://proxy.example.com:8080"   # ← https:// ではなく http://
export no_proxy="localhost,127.0.0.1"
```

> **重要**: `https_proxy` に `https://` を指定するのは誤りです。  
> プロキシサーバー自体への接続は常に平文 HTTP で行われるため、`http://` を使用します。

追記後、設定を反映します。

```bash
source ~/.bashrc
```

#### (b) apt のプロキシ設定

```bash
sudo tee /etc/apt/apt.conf.d/99proxy << 'EOF'
Acquire::http::Proxy "http://proxy.example.com:8080";
Acquire::https::Proxy "http://proxy.example.com:8080";
EOF
```

#### (c) SSL インスペクションがある場合（社内 CA 証明書の登録）

プロキシが HTTPS 通信を復号する構成（SSL インスペクション）の場合、  
社内 CA 証明書を IT 部門から入手し、以下の手順で登録します。

```bash
sudo cp 社内CA証明書.crt /usr/local/share/ca-certificates/company-ca.crt
sudo update-ca-certificates
```

登録後、curl で外部へ接続できるか確認します。

```bash
curl -I https://get.docker.com
# HTTP/1.1 200 などが返れば成功
```

---

### 手順3: Docker Engine のセットアップ

#### (a) systemd の有効化（初回のみ・要 WSL2 再起動）

WSL2 上で systemd を有効化します。`/etc/wsl.conf` を編集します。

```bash
sudo tee /etc/wsl.conf << 'EOF'
[boot]
systemd=true
EOF
```

編集後、**PowerShell** 側で WSL2 を再起動します。

```powershell
wsl --shutdown
```

再起動後、WSL2 のターミナルを再度開きます。

#### (b) セットアップスクリプトの実行

```bash
cd ~/static-curl-build
chmod +x setup_docker_wsl2.sh
./setup_docker_wsl2.sh
```

スクリプトが以下を自動的に行います。

1. systemd の有効化確認
2. Docker デーモン用プロキシ設定（`/etc/systemd/system/docker.service.d/http-proxy.conf`）
3. Docker Engine のインストール
4. ユーザーの `docker` グループへの追加
5. Docker サービスの起動
6. QEMU（ARM エミュレーター）の登録
7. Docker Buildx の設定（マルチプラットフォームビルド用）
8. ARM エミュレーションの動作確認

> **プロキシ設定について**  
> `~/.bashrc` に環境変数が設定済みであれば、スクリプトが自動的に検出して  
> Docker デーモン用の設定ファイルを生成します。  
> Docker デーモンは root プロセスのため `~/.bashrc` を参照しません。  
> スクリプトが `/etc/systemd/system/docker.service.d/http-proxy.conf` を  
> 生成することで、`docker pull` 等のデーモン操作にプロキシが適用されます。

#### (c) docker グループの反映

セットアップ完了後、グループ変更を現在のシェルに反映します。

```bash
exec newgrp docker

# Docker が使えるか確認
docker --version
docker info
```

---

### 手順4: ビルドの実行

1. build.shの中のプロキシ設定、その他設定を変更する
2. Dockerfileの中のプロキシ設定はbuild.shの設定を引き継ぐはずなので変更不要だが、ビルド対象パッケージのバージョン指定を書き換えておく


```bash
chmod +x build.sh
./build.sh
```

初回は OpenSSL・curl のソースのダウンロード＋コンパイルが走るため、  
**10〜20分程度**かかります（2回目以降はキャッシュが効くため数分）。

---

### 手順5: 生成物の確認

```bash
ls -lh output/curl
readelf -h output/curl | grep -E "Class|Machine"
# 出力例:
#   Class:    ELF32
#   Machine:  ARM
```

---

## ターゲット機器 (MA-E300) へのデプロイ

```bash
# バイナリをコピー
scp output/curl admin@<デバイスIP>:/usr/local/bin/curl

# 実行権限を付与
ssh admin@<デバイスIP> 'chmod +x /usr/local/bin/curl'

# 動作確認
ssh admin@<デバイスIP> 'curl --version'
# "curl 8.x.x ... OpenSSL/3.5.x" と表示されれば成功
```

### 既存の curl を置き換える場合

```bash
ssh admin@<デバイスIP> '
    # 念のため旧バイナリをバックアップ
    cp /usr/bin/curl /usr/bin/curl.bak.openssl3.0
    # /usr/local/bin は /usr/bin より優先されるため which で確認
    which curl
    curl --version
'
```

---

## バージョンの変更方法

`build.sh` の先頭部分を編集してください。

```bash
OPENSSL_VER="3.5.4"   # OpenSSL のバージョン
CURL_VER="8.13.0"     # curl のバージョン
```

---

## トラブルシューティング

### Docker サービスが起動しない

```bash
sudo systemctl start docker
sudo systemctl status docker
```

`/etc/wsl.conf` の systemd 設定と WSL2 の再起動が済んでいるか確認してください。

### `exec format error` が出る場合

QEMU の登録が必要です。

```bash
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

### `docker pull` がプロキシを通れない場合

Docker デーモン用のプロキシ設定を確認します。

```bash
cat /etc/systemd/system/docker.service.d/http-proxy.conf
# [Service]
# Environment="HTTP_PROXY=http://..."
# Environment="HTTPS_PROXY=http://..."
```

設定後はデーモンを再起動します。

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### ビルドが途中で失敗する場合

キャッシュをクリアして再試行してください。

```bash
docker builder prune -f
./build.sh
```

### `curl: (60) SSL certificate problem` になる場合

静的バイナリには CA 証明書バンドルが含まれていません。  
ターゲット機器の `/etc/ssl/certs/ca-certificates.crt` を参照しているので、  
証明書が古い場合は以下で更新してください。

```bash
# MA-E300 上で実行
sudo update-ca-certificates
```

### Windows 側から WSL2 の output/ フォルダを開く

エクスプローラーのアドレスバーに以下を入力：

```
\\wsl$\Ubuntu\home\<ユーザー名>\static-curl-build\output
```

---

## 仕組みの概要

```
WSL2 (Ubuntu)
└─ Docker Engine (linux/arm/v7 プラットフォーム指定)
   └─ QEMU arm エミュレーション
      └─ ubuntu:24.04 (armhf)
         ├─ OpenSSL 3.5.x をソースからビルド（静的ライブラリ、linux-armv4ターゲット）
         └─ curl をOpenSSL 3.5 に静的リンクしてビルド
            └─ output/curl  ← armhf スタンドアロンバイナリ
```

`--disable-shared` + `LDFLAGS="-static"` により、libssl・libcrypto・libz  
すべてがバイナリ内に取り込まれ、ターゲット機器の OpenSSL バージョンに  
依存しない完全スタンドアロン実行ファイルになります。

### 生成バイナリの確認ポイント

```bash
readelf -h output/curl | grep -E "Class|Machine"
# 正しい出力例:
#   Class:    ELF32
#   Machine:  ARM        ← ここが ARM であることを確認
```