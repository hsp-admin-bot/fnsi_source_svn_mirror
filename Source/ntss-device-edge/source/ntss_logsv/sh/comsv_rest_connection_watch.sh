#!/bin/sh

timeout="--connect-timeout 6 -m 10"
MKTEMP="mktemp -t connection_watch.XXXXXX"

url=${1}
response_file=${2}
error_file=${3}

seckey="NTSS-NKK-ESM-TDC-YSK"
header="SSECCAYEK:${seckey}"
echo "params: [${url}]"

# 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
LAST_ERROR_NO=0
get_file="$($MKTEMP)"
# echoで\nが改行コードとして認識されないのでprintfでシェバング部分を作っておく
shebang_curl=$(printf "#!/bin/sh\ncurl")
echo "${shebang_curl} ${url} -Ssf ${timeout} -X GET -H '${header}' -o /dev/null -w %{http_code} 2> '${error_file}'" >${get_file}
chmod 777 ${get_file}
LAST_ERROR_NO=$(${get_file})
rm -f ${get_file}

echo ${LAST_ERROR_NO} >${response_file}
echo "get response: "${LAST_ERROR_NO}

exit ${LAST_ERROR_NO}
