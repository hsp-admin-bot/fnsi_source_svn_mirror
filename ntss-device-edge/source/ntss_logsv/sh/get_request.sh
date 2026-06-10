#!/bin/sh
timeout="--connect-timeout 30 -m 60"
MKTEMP="mktemp -t get-main-api.XXXXXX"
  url=${1}
# echo "url=${url}"
  data_file=${2}
  response_file=${3}
  error_file=${4}
  seckey="NTSS-NKK-ESM-TDC-YSK"
  header1="content-type:application/json"
  header2="cache-control:no-cache"
  header3="SSECCAYEK:${seckey}"
# echo "body=${body}"
  content="$(printf "{${body}}")"
# echo ${content}

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0  
  get_file="$($MKTEMP)"
  # echoで\nが改行コードとして認識されないのでprintfでシェバング部分を作っておく
  shebang_curl=$(printf "#!/bin/sh\ncurl")
  echo "${shebang_curl} ${url} -Ssf ${timeout} -X GET -H '${header1}' -H '${header2}' -H '${header3}' -d '${content}' -o '${data_file}' -w %{http_code} 2> '${error_file}'" > ${get_file}
  chmod 777 ${get_file} 
  LAST_ERROR_NO=$(${get_file})
  rm -f ${get_file}

  echo ${LAST_ERROR_NO} > ${response_file}
  echo "request response: "${LAST_ERROR_NO}
  exit ${LAST_ERROR_NO}
