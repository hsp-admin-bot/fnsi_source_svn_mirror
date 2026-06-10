#!/bin/sh

# ファイルをAPIに対してPOSTする
# post_data_file.sh {url} {upload_file} {facility_cd} {device_edge_no}

timeout="--connect-timeout 30 -m 60"
MKTEMP="mktemp -t post_file.XXXXXX"
  url=${1}
# echo "url=${url}"
  upload_file=${2}
  facility_cd=${3}
  device_edge_no=${4}
  response_file=${5}
  error_file=${6}
  seckey="NTSS-NKK-ESM-TDC-YSK"
# echo "upload_file=${upload_file}"
  header1="cache-control:no-cache"
  header2="facility_cd:${facility_cd}"
  header3="device_edge_no:${device_edge_no}"
  header4="SSECCAYEK:${seckey}"
# echo "file64str=${file64str}"
# echo ${content}

# 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0  
  put_file="$($MKTEMP)"
# echoで\nが改行コードとして認識されないのでprintfでシェバング部分を作っておく
  shebang_curl=$(printf "#!/bin/sh\ncurl") 
  echo "${shebang_curl} ${url} -Ssf -k ${timeout} -X POST -H '${header1}' -H '${header2}' -H '${header3}' -H '${header4}' -T '${upload_file}' -o /dev/null -w %{http_code} 2> '${error_file}'" > ${put_file}
  chmod 777 ${put_file} 
  LAST_ERROR_NO=$(${put_file})
  rm -f ${put_file}

  echo ${LAST_ERROR_NO} > ${response_file}
  echo "upload response: "${LAST_ERROR_NO}
  exit ${LAST_ERROR_NO}
