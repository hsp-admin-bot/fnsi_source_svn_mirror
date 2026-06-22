#!/bin/sh
timeout="--connect-timeout 30 -m 60"
MKTEMP="mktemp -t post_b64.XXXXXX"
  url=${1}
# echo "url=${url}"
  upload_file=${2}
  response_file=${3}
  error_file=${4}
  seckey="NTSS-NKK-ESM-TDC-YSK"
# echo "upload_file=${upload_file}"
  header1="content-type:application/json"
  header2="cache-control:no-cache"
  header3="SSECCAYEK:${seckey}"
  body=$(cat "${upload_file}")
# echo "body=${body}"
  content="$(printf "{${body}}")"
# echo ${content}

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0  
  put_file="$($MKTEMP)"
  # echoで\nが改行コードとして認識されないのでprintfでシェバング部分を作っておく
  shebang_curl=$(printf "#!/bin/sh\ncurl") 
  echo "${shebang_curl} ${url} -Ssf -k ${timeout} -X POST -H '${header1}' -H '${header2}' -H '${header3}' -d '${content}' -o /dev/null -w %{http_code} 2> '${error_file}'" > ${put_file}
  chmod 777 ${put_file} 
  LAST_ERROR_NO=$(${put_file})
  rm -f ${put_file}

  echo ${LAST_ERROR_NO} > ${response_file}
  echo "upload response: "${LAST_ERROR_NO}
  exit ${LAST_ERROR_NO}
