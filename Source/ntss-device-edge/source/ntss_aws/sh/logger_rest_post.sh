#!/bin/sh
timeout="--connect-timeout 30 -m 60"
MKTEMP="mktemp -t comsv_rest_post.XXXXXX"
  url=${1}
  if [ $# -eq 4 ]; then
    upload_data=${2}
    response_file=${3}
    error_file=${4}
    params=""
#    echo "Parameter 4"
  elif [ $# -eq 5 ]; then
    upload_data=${3}
    response_file=${4}
    error_file=${5}
    params="/${2}"
#    echo "Parameter 5"
  elif [ $# -eq 6 ]; then
    upload_data=${4}
    response_file=${5}
    error_file=${6}
    params="/${2}/${3}"
#    echo "Parameter 6"
  elif [ $# -eq 7 ]; then
    upload_data=${5}
    response_file=${6}
    error_file=${7}
    params="/${2}/${3}/${4}"
#    echo "Parameter 7"
  elif [ $# -eq 8 ]; then
    upload_data=${6}
    response_file=${7}
    error_file=${8}
    params="/${2}/${3}/${4}/${5}"
#    echo "Parameter 8"
  elif [ $# -eq 9 ]; then
    upload_data=${7}
    response_file=${8}
    error_file=${9}
    params="/${2}/${3}/${4}/${5}/${6}"
#    echo "Parameter 9"
  else
#    echo "Parameter Error($#)"
    exit 0
  fi
  # echo "url=${url}"
  seckey="NTSS-NKK-ESM-TDC-YSK"
  # echo "upload_file=${upload_file}"
  header1="content-type:application/json"
  header2="cache-control:no-cache"
  header3="SSECCAYEK:${seckey}"

  content=${upload_data}

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0  
  post_file="$($MKTEMP)"
  # echoで\nが改行コードとして認識されないのでprintfでシェバング部分を作っておく
  shebang_curl=$(printf "#!/bin/sh\ncurl") 
  echo "${shebang_curl} ${url}${params} -Ssf ${timeout} -X POST -H '${header1}' -H '${header2}' -H '${header3}' -d '${content}' -o /dev/null -w %{http_code} 2> '${error_file}'" > ${post_file}
  chmod 777 ${post_file} 
  LAST_ERROR_NO=$(${post_file})
  rm -f ${post_file}

 #echo ${LAST_ERROR_NO} > ${response_file}
 # echo "post response: "${LAST_ERROR_NO}
  exit ${LAST_ERROR_NO}
