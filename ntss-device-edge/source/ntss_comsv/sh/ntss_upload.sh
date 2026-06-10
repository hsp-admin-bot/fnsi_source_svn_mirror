#!/bin/sh
timeout="--connect-timeout 30 -m 60"
MKTEMP="mktemp -t ntss.api.upload.XXXXXX"
  url=$1
#  upload_path=$2
  upload_path=$(echo -n $2 | base64 -w 0)
  upload_file=$3
  log1=$4
  log2=$5
  seckey="NTSS-NKK-ESM-TDC-YSK"

  rm -f ${log1}
  rm -f ${log2}

#  echo "URL:"${url}
#  echo "path:"${upload_path}
#  echo "path(b64):"$(echo ${upload_path} | base64 -w 0)
#  echo "file:"${upload_file}
#  echo "log1:"${log1}
#  echo "log2:"${log2}

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0
  put_file="$($MKTEMP)"
  echo "#!/bin/sh\ncurl -Ssf -k ${timeout} ${url} -X POST -H 'SSECCAYEK:${seckey}' -F 'file=@${upload_file}' -F 'filePath=${upload_path}' -o /dev/null -w %{http_code} > '${log1}' 2> '${log2}'" > ${put_file}
  chmod 777 ${put_file} 
  LAST_ERROR_NO=$(${put_file})
#  echo "script:"${put_file}
  rm -f ${put_file}

  echo "upload response: "${LAST_ERROR_NO}
  exit ${LAST_ERROR_NO}

