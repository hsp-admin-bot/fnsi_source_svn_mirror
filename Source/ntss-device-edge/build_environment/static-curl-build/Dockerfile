# ============================================================
# static-curl-armhf builder
# ターゲット: TI Sitara AM3352 (ARM Cortex-A8 / ARMv7-A)
# ベースイメージ: Ubuntu 24.04 (Noble) armhf
# 生成物: OpenSSL 3.5 + curl を静的リンクした armhf バイナリ
# プロキシ対応版
# ============================================================
FROM --platform=linux/arm/v7 ubuntu:24.04

# -------------------------------------------------------
# プロキシ設定
# build.sh から --build-arg で渡される。
# 不要な場合は空のまま（ARG だけ宣言しておいても無害）
# -------------------------------------------------------
ARG http_proxy=""
ARG https_proxy=""
ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""
ARG no_proxy=""
ARG NO_PROXY=""

# ENV に昇格させることでコンテナ内の全コマンド（apt, wget 等）に適用される
ENV http_proxy=${http_proxy} \
    https_proxy=${https_proxy} \
    HTTP_PROXY=${HTTP_PROXY} \
    HTTPS_PROXY=${HTTPS_PROXY} \
    no_proxy=${no_proxy} \
    NO_PROXY=${NO_PROXY}

# ビルドに必要なパッケージをインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    ca-certificates \
    perl \
    pkg-config \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------
# バージョン設定（変更する場合はここだけ書き換える）
# -------------------------------------------------------
ARG OPENSSL_VERSION=3.5.7
ARG CURL_VERSION=8.20.0
ARG NGHTTP2_VERSION=1.69.0

WORKDIR /build

# -------------------------------------------------------
# 1. OpenSSL 3.5 のビルド（静的ライブラリのみ）
#    linux-armv4  = OpenSSL の ARMv4以降汎用ターゲット
#    （ARMv7/Cortex-A8 でも動作する最も安全な選択）
# -------------------------------------------------------
RUN wget -q https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz \
    && tar xf openssl-${OPENSSL_VERSION}.tar.gz \
    && cd openssl-${OPENSSL_VERSION} \
    && ./Configure \
        --prefix=/opt/openssl \
        --openssldir=/opt/openssl/ssl \
        linux-armv4 \
        no-shared \
        no-tests \
    && make -j$(nproc) \
    && make install_sw \
    && cd /build && rm -rf openssl-${OPENSSL_VERSION}*

# -------------------------------------------------------
# 2 before. nghttp2 のビルド（HTTP/2 サポート用静的ライブラリ）
# -------------------------------------------------------
RUN wget -q https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz \
    && tar xf nghttp2-${NGHTTP2_VERSION}.tar.gz \
    && cd nghttp2-${NGHTTP2_VERSION} \
    && ./configure \
        --prefix=/opt/nghttp2 \
        --disable-shared \
        --enable-static \
        --disable-python-bindings \
        --disable-examples \
        --disable-app \
        OPENSSL_CFLAGS="-I/opt/openssl/include" \
        OPENSSL_LIBS="-L/opt/openssl/lib -lssl -lcrypto" \
    && make -j$(nproc) \
    && make install \
    && cd /build && rm -rf nghttp2-${NGHTTP2_VERSION}*

# -------------------------------------------------------
# 2. curl のビルド（OpenSSL 3.5 に静的リンク）
# -------------------------------------------------------
RUN wget -q https://curl.se/download/curl-${CURL_VERSION}.tar.gz \
    && tar xf curl-${CURL_VERSION}.tar.gz \
    && cd curl-${CURL_VERSION} \
    && PKG_CONFIG_PATH=/opt/openssl/lib/pkgconfig \
       ./configure \
           --prefix=/opt/curl \
           --with-openssl=/opt/openssl \
           --with-nghttp2=/opt/nghttp2 \
           --disable-shared \
           --enable-static \
           --disable-ldap \
           --disable-ldaps \
           --without-libpsl \
           LDFLAGS="-static" \
           LIBS="-ldl -lpthread" \
    && make -j$(nproc) \
    && make install \
    && cd /build && rm -rf curl-${CURL_VERSION}*

# -------------------------------------------------------
# 3. 生成バイナリの確認
# -------------------------------------------------------
RUN echo "=== OpenSSL バージョン確認 ===" \
    && /opt/curl/bin/curl --version \
    && echo "=== アーキテクチャ確認 ===" \
    && readelf -h /opt/curl/bin/curl | grep -E "Class|Machine"

# -------------------------------------------------------
# 4. ビルド完了後はプロキシ設定を除去
#    （生成バイナリ自体にはプロキシ情報は残らないが念のため）
# -------------------------------------------------------
ENV http_proxy="" \
    https_proxy="" \
    HTTP_PROXY="" \
    HTTPS_PROXY="" \
    no_proxy="" \
    NO_PROXY=""
