#!/bin/sh
# S3へのアップロード確認用スクリプト(開発環境)
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
 "AKIAI3BBPXCSRQAHDVZA"                                \
 "FpL+6PFhmF0CcdvKFpAsJUl7NpsSe0FymgvXr0I5"            \
 "y2AXo1QwYslwdsop01Q11nNQjBRT5BK4PFqqBcji"            \
 "ap-northeast-1"                                      \
 "execute-api"                                         \
 "c6q4tmwurc.execute-api.ap-northeast-1.amazonaws.com" \
 "/ntss_gateway_s3/ntss-s3-root/000001/dummy.zip"      \
 "application/octet-stream"                            \
 "authenticated-read"                                  \
 "./dummy.zip"                                         #
echo ret: $?
