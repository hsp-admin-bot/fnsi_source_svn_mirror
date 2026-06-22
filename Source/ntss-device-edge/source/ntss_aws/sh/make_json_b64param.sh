#!/bin/sh

# JSONの key:value(base64) 形式をファイルに出力
# 引数
# key キー文字列
# value base64化するデータが格納されたファイル
# output_file 出力ファイル
# is_append 0:追記(先頭にカンマ付与) 1:新規

key=${1}
value_file=${2}
output_file=${3}
is_append=${4}

file64str=$(base64 "${value_file}" -w 0)
# echo "file64str=${file64str}"
content="$(printf "\"${key}\":\"${file64str}\"")"
# echo ${content}

LAST_ERROR_NO=0  

if [ ${is_append} -eq 0 ]; then
  echo -n "," ${content} >> ${output_file}
else
  echo -n ${content} > ${output_file}
fi

LAST_ERROR_NO=$?

exit ${LAST_ERROR_NO}