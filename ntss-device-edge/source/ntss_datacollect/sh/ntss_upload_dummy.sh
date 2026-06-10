#!/bin/sh
MKTEMP="mktemp -t data_gathering.api.upload.XXXXXX"
  aws_host=$1
  address=$2
  facility_cd=$3
  upload_file=$4

  # url作成
  url=${aws_host}${address}

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0
#  put_file="$($MKTEMP)"
#  echo "#!/bin/sh\ncurl -Ssf ${url} -X POST -F 'file=@${upload_file}' -F 'facilityCd=${facility_cd}' -o /dev/null -w %{http_code}" > ${put_file}
#  chmod 777 ${put_file} 
#  LAST_ERROR_NO=$(${put_file})
#  rm -f ${put_file}
#
#  echo "upload response: "${LAST_ERROR_NO}
#  exit ${LAST_ERROR_NO}


  echo "#!/bin/sh\ncurl -Ssf ${url} -X POST -F 'file=@${upload_file}' -F 'facilityCd=${facility_cd}' -o /dev/null -w %{http_code}" >> "curl_dummy.txt"
  exit 200

