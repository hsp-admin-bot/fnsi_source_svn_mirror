#!/bin/sh
timeout="--connect-timeout 30 -m 60"
MKTEMP="mktemp -t dl_s3.XXXXXX"
  url=${1}
  bucket=${2}
  filename=${3}
  response_file=${4}
  error_file=${5}
  temp_file=${6}
  seckey="NTSS-NKK-ESM-TDC-YSK"
  header1="content-type:application/json"
  header2="cache-control:no-cache"
  header3="SSECCAYEK:${seckey}"
  content="$(printf "{\"bucket\":\"${bucket}\",\"filename\":\"${filename}\"}")"
  echo "content: ${content}"

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0  
  put_file="$($MKTEMP)"
  # echoで\nが改行コードとして認識されないのでprintfでシェバング部分を作っておく
  shebang_curl=$(printf "#!/bin/sh\ncurl") 
  echo "${shebang_curl} ${url} -Ssf -k ${timeout} -X POST -H '${header1}' -H '${header2}' -H '${header3}' -d '${content}' -o '${temp_file}' -w %{http_code} 2> '${error_file}'" > ${put_file}
  chmod 777 ${put_file} 
  LAST_ERROR_NO=$(${put_file})
  rm -f ${put_file}

  echo ${LAST_ERROR_NO} > ${response_file}
  echo "upload response: "${LAST_ERROR_NO}
  exit ${LAST_ERROR_NO}
