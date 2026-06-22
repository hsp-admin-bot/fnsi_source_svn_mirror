#!/bin/sh
MKTEMP="mktemp -t comsv_zip_post.XXXXXX"
  url=${1}
  # 透析番号
  ord_no=${2}
  # ダウンロードファイル名
  download_data=${3}
  response_file=${4}
  error_file=${5}

  seckey="NTSS-NKK-ESM-TDC-YSK"
  header1="SSECCAYEK:${seckey}"
  header2="ord_no:${ord_no}"
  # 圧縮ファイル名
  output_dir=$(dirname ${download_data}) 
  bin_data="${output_dir}/${ord_no}.zip"
  echo "url: [${url}]"

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0  
  put_file="$($MKTEMP)"
  echo "sudo curl ${url} -Ssf --connect-timeout 10 -m 30 -X POST -H '${header1}' -H '${header2}' -o '${download_data}' -w %{http_code} 2> '${error_file}'" > ${put_file}
  chmod 777 ${put_file} 
  LAST_ERROR_NO=$(${put_file})
  rm -f ${put_file}

  echo ${LAST_ERROR_NO} > ${response_file}
  echo "download response: "${LAST_ERROR_NO}

  # curl成功判定
  if [ ${LAST_ERROR_NO} -eq 200 ]; then
    # 成功した場合

    # ダウンロードファイルチェック
    if [ -s ${download_data} ]; then
      # ファイルが存在（0バイト以外）

      # テキストバイナリ→バイナリ変換
      sudo chmod 777 ${download_data}
      xxd -r -p ${download_data} > ${bin_data}
    fi
  fi

  # ダウンロードファイル存在チェック
  if [ -e ${download_data} ]; then
    # ダウンロードファイルを削除
    sudo rm -f ${download_data}
  fi

  exit ${LAST_ERROR_NO}
