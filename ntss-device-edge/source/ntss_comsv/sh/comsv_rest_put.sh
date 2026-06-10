#!/bin/sh
timeout="--connect-timeout 30 -m 60"
MKTEMP="mktemp -t comsv_rest_put.XXXXXX"
  url=${1}
  if [ $# -eq 3 ]; then
    response_file=${2}
    error_file=${3}
    params=""
    #echo "Parameter 3"
  elif [ $# -eq 4 ]; then
    response_file=${3}
    error_file=${4}
    params="/${2}"
    echo "Parameter 4"
  elif [ $# -eq 5 ]; then
    response_file=${4}
    error_file=${5}
    params="/${2}/${3}"
    echo "Parameter 5"
  elif [ $# -eq 6 ]; then
    response_file=${5}
    error_file=${6}
    params="/${2}/${3}/${4}"
    echo "Parameter 6"
  elif [ $# -eq 7 ]; then
    response_file=${6}
    error_file=${7}
    params="/${2}/${3}/${4}/${5}"
    echo "Parameter 7"
  elif [ $# -eq 8 ]; then
    response_file=${7}
    error_file=${8}
    params="/${2}/${3}/${4}/${5}/${6}"
    echo "Parameter 8"
  elif [ $# -eq 9 ]; then
    response_file=${8}
    error_file=${9}
    params="/${2}/${3}/${4}/${5}/${6}/${7}"
    echo "Parameter 9"
 elif [ $# -eq 10 ]; then
    response_file=${9}
    error_file=${10}
    params="/${2}/${3}/${4}/${5}/${6}/${7}/${8}"
    echo "Parameter 10"
 elif [ $# -eq 11 ]; then
    response_file=${10}
    error_file=${11}
    params="/${2}/${3}/${4}/${5}/${6}/${7}/${8}/${9}"
    echo "Parameter 11"
 elif [ $# -eq 12 ]; then
    response_file=${11}
    error_file=${12}
    params="/${2}/${3}/${4}/${5}/${6}/${7}/${8}/${9}/${10}"
    echo "Parameter 12"
 elif [ $# -eq 13 ]; then
    response_file=${12}
    error_file=${13}
    params="/${2}/${3}/${4}/${5}/${6}/${7}/${8}/${9}/${10}/${11}"
    echo "Parameter 13"

  else
    echo "Parameter Error($#)"
    exit 0
  fi

  seckey="NTSS-NKK-ESM-TDC-YSK"
  header="SSECCAYEK:${seckey}"
  #echo "params: [${url}${params}]"

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0  
  put_file="$($MKTEMP)"
  # echoで\nが改行コードとして認識されないのでprintfでシェバング部分を作っておく
  shebang_curl=$(printf "#!/bin/sh\ncurl") 
  echo "${shebang_curl} ${url}${params} -Ssf ${timeout} -X PUT -H 'Content-Length: 0' -H '${header}' -o /dev/null -w %{http_code} 2> '${error_file}'" > ${put_file}
  chmod 777 ${put_file} 
  LAST_ERROR_NO=$(${put_file})
  rm -f ${put_file}

  echo ${LAST_ERROR_NO} > ${response_file}
  #echo "put response: "${LAST_ERROR_NO}
  exit ${LAST_ERROR_NO}
