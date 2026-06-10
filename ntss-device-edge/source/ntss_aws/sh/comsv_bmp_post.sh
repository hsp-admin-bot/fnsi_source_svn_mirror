#!/bin/sh
MKTEMP="mktemp -t comsv_bmp_post.XXXXXX"
  url=${1}
  ord_no=${2}
  download_data=${3}
  response_file=${4}
  error_file=${5}

  seckey="NTSS-NKK-ESM-TDC-YSK"
  header1="SSECCAYEK:${seckey}"
  header2="ord_no:${ord_no}"
  bin_data="${download_data}.zip"
  output_dir=$(dirname ${download_data})
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

  if [ ${LAST_ERROR_NO} -eq 200 ]; then
    # #9110 2023.08.09 mod REST応答が正常でもVA画像の有無をチェックする TDC高村 start
    #sudo chmod 777 ${download_data}
    #xxd -r -p ${download_data} > ${bin_data}
    #unzip -o ${bin_data} -d ${output_dir}
    #rm -f ${download_data}
    #rm -f ${bin_data}
    if [ -s ${download_data} ]; then
      # ファイルが存在（0バイト以外）
      sudo chmod 777 ${download_data}
      xxd -r -p ${download_data} > ${bin_data}
      unzip -o ${bin_data} -d ${output_dir}
      rm -f ${download_data}
      rm -f ${bin_data}
    fi
    # #9110 2023.08.09 mod REST応答が正常でもVA画像の有無をチェックする TDC高村 end
  fi
  
  # #12330 2025.10.14 add {dawnload_data}が残っている場合は削除する TDC米沢 start
  if [ -e ${download_data} ]; then
    sudo rm -f ${download_data}
  fi
  # #12330 2025.10.14 add {dawnload_data}が残っている場合は削除する TDC米沢 end

  exit ${LAST_ERROR_NO}
