#!/bin/sh
# S3へのアップロード確認用スクリプト(検証環境)
#
# $1 :IAMユーザーキー
# $2 :IAMシークレットキー
# $3 :APIキー
# $4 :AWSリージョン
# $5 :AWSサービス名
# $6 :AWSホスト名
# $7 :AWSアドレス
# $8 :ファイル種別
# $9 :ファイルセキュリティ
# $10:アップロードファイル

./ntss_upload.sh\
 "AKIAJW7W5QEYFWNQXEQQ"                                \
 "HkDNp/s7Bvc+B2o4W9NzDe1a9FYgfzjPbePde99y"            \
 "5BJ6VVDJ9fZ8svy40b5I24ebPxrk7CK4j97bAmsd"            \
 "ap-northeast-1"                                      \
 "execute-api"                                         \
 "bd7b4ncaab.execute-api.ap-northeast-1.amazonaws.com" \
 "/ntss_gateway_s3/ntss-s3-root-verification/000000/dummy.zip"      \
 "application/octet-stream"                            \
 "authenticated-read"                                  \
 "./dummy.zip"                                         #
echo ret: $?
