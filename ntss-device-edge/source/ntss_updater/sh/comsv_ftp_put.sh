#!/bin/sh
MKTEMP="mktemp -t comsv_ftp_put.XXXXXX"
  FTP_URL=${1}
  FTP_USER=${2}
  FTP_PASS=${3}
  FTP_FOLDER=${4}
  FTP_PUT_FILE=${5}
  response_file=${6}
  error_file=${7}

  FTP_CURL_OPTION="-Ssf --connect-timeout 30 -m 60"

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0  
  put_file="$($MKTEMP)"
  echo "sudo curl -T '${FTP_PUT_FILE}' -u '${FTP_USER}:${FTP_PASS}' -ssl -k ftp://${FTP_URL}/${FTP_FOLDER}/ -w %{http_code} 2> '${error_file}'" > ${put_file}
  chmod 777 ${put_file}
  LAST_ERROR_NO=$(${put_file})
  rm -f ${put_file}

  echo ${LAST_ERROR_NO} > ${response_file}
  echo "ftp response: "${LAST_ERROR_NO}

#  if [ ${LAST_ERROR_NO} -eq 226 ]; then
#    rm -f ${FTP_PUT_FILE}
#  fi

  exit ${LAST_ERROR_NO}
