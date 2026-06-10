#!/bin/sh
timeout="--connect-timeout 30 -m 60"
MKTEMP="mktemp -t comsv_rest_get.XXXXXX"
  url=${1}
  if [ $# -eq 4 ]; then
    response_file=${2}
    error_file=${3}
    data_file=${4}
    params=""
    echo "Parameter 4"
  elif [ $# -eq 5 ]; then
    response_file=${3}
    error_file=${4}
    data_file=${5}
    params="/${2}"
    echo "Parameter 5"
  elif [ $# -eq 6 ]; then
    response_file=${4}
    error_file=${5}
    data_file=${6}
    params="/${2}/${3}"
    echo "Parameter 6"
  elif [ $# -eq 7 ]; then
    response_file=${5}
    error_file=${6}
    data_file=${7}
    params="/${2}/${3}/${4}"
    echo "Parameter 7"
  elif [ $# -eq 8 ]; then
    response_file=${6}
    error_file=${7}
    data_file=${8}
    params="/${2}/${3}/${4}/${5}"
    echo "Parameter 8"
  elif [ $# -eq 9 ]; then
    response_file=${7}
    error_file=${8}
    data_file=${9}
    params="/${2}/${3}/${4}/${5}/${6}"
    echo "Parameter 9"
  elif [ $# -eq 10 ]; then
    response_file=${8}
    error_file=${9}
    data_file=${10}
    params="/${2}/${3}/${4}/${5}/${6}/${7}"
    echo "Parameter 10"
  else
    echo "Parameter Error($#)"
    exit 0
  fi

  seckey="NTSS-NKK-ESM-TDC-YSK"
  header="SSECCAYEK:${seckey}"
  echo "params: [${url}${params}]"

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0  
  get_file="$($MKTEMP)"
  # echoで\nが改行コードとして認識されないのでprintfでシェバング部分を作っておく
  shebang_curl=$(printf "#!/bin/sh\ncurl") 
  echo "${shebang_curl} ${url}${params} -Ssf ${timeout} -X GET -H '${header}' -o '${data_file}' -w %{http_code} 2> '${error_file}'" > ${get_file}
  chmod 777 ${get_file} 
  LAST_ERROR_NO=$(${get_file})
  rm -f ${get_file}

  echo ${LAST_ERROR_NO} > ${response_file}
  echo "get response: "${LAST_ERROR_NO}

  if [ ${LAST_ERROR_NO} -eq 200 ]; then
    # json文字列のゴミ削除
    sed -i -e 's/\\"/\"/g' -e 's/:\"{/:{/g' -e 's/\"}\"/\"}/g' -e 's/]}\"/]}/g' -e 's/:\"\[{/:[{/g' -e 's/}]\"/}]/g'  -e 's/}}\"/}}/g' -e 's/}}\",}/}},/g' -e 's/}\",/},/g' -e 's/\\\\/\\/g' ${data_file}
    json_head=$(head -c 1 ${data_file})
    if [ ${json_head} = "[" ]; then
      # List形式データの場合はタグを作成
      sed -i '1i {\"ListData\":' ${data_file}
      sed -i '$a }' ${data_file}
    fi
  fi

  exit ${LAST_ERROR_NO}
