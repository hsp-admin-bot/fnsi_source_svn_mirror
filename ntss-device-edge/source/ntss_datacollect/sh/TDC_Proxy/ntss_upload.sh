#!/bin/sh
MKTEMP="mktemp -t aws-sign.XXXXXX"
hash() {
  printf "%s" "$1"                       | 
  openssl dgst -sha256                   | 
  awk '{print $2}'                       #
}
filehash() {
  openssl dgst -sha256 "$1"              | 
  awk '{print $2}'                       #
}
filesize() {
  wc -c "$1" | awk '{print $1}'
}
hex() {
  od -An -vtx1 | sed 's/[ \n]//g' | tr -d '\n'
}
hmac() {
  local keyfile="$1" data="$2"           #
  printf '%s' "$data"                    | 
  openssl dgst                           \
    -sha256                              \
    -mac HMAC                            \
    -macopt hexkey:"$( hex < $keyfile )" \
    -binary                              #
}
derive_string_key() {
  local user_secret="$1" 
  local message_date="$2"
  local aws_region="$3"
  local aws_service="$4"
  step0="$($MKTEMP)"
  step1="$($MKTEMP)"
  step2="$($MKTEMP)"
  step3="$($MKTEMP)"
  printf '%s' "AWS4${user_secret}" > "$step0"
  hmac "$step0" "${message_date}" > "$step1"
  hmac "$step1" "${aws_region}" > "$step2"
  hmac "$step2" "${aws_service}" > "$step3"
  hmac "$step3" "aws4_request"
  rm -f $step0 $step1 $step2 $step3
}

  u_key=$1
  u_secret=$2
  aws_api_key=$3
  aws_region=$4
  aws_service=$5
  aws_host=$6
  address=$7
  aws_content_type=$8
  aws_acl=$9
  upload_file=${10}
  query_strings=""
  request_payload=""
  url="https://"${aws_host}${address}
  upload_file_hash=$(filehash "$upload_file")
  upload_file_size=$(filesize "$upload_file")
  message_date=$(date --utc +%F | tr -d '-')
  message_time=$(date --utc +%Y%m%dT%H%M%SZ)
#  echo "u_key: ${u_key}"
#  echo "u_secret: ${u_secret}"
#  echo "api-key: ${aws_api_key}"
#  echo "aws_region: ${aws_region}"
#  echo "aws_service: ${aws_service}"
#  echo "aws_host: ${aws_host}"
#  echo "address: ${address}"
#  echo "content-Ttpe: ${aws_content_type}"
#  echo "aws_acl: ${aws_acl}"
#  echo "upload_file: ${upload_file}"
#  echo "upload_file_hash: ${upload_file_hash}"
#  echo "upload_file_size: ${upload_file_size}"
#  echo "query_strings: ${query_strings}"
#  echo "request_payload: ${request_payload}"
#  echo "aws_endpoint: ${aws_endpoint}"
#  echo "url: ${url}"
#  echo "Amz-Date: ${message_date}"
#  echo "X-Amz-Date: ${message_time}"

#  echo -e
  headers="$(printf "content-type:${aws_content_type}\nhost:${aws_host}\nx-amz-date:${message_time}\nx-api-key:${aws_api_key}")"
#  echo "headers: $headers"
  header_list="content-type;host;x-amz-date;x-api-key"
#  echo "header_list: $header_list"
#  canonical_request="$(printf "PUT\n${address}\n%s\n${headers}\n\n${header_list}\n%s" "${query_strings}" "$(hash "$request_payload")")"
  canonical_request="$(printf "PUT\n${address}\n%s\n${headers}\n\n${header_list}\n%s" "${query_strings}" "${upload_file_hash}")"
#  echo "canonical_request: $canonical_request"
  canonical_request_hash=$(hash "$canonical_request")
#  echo "canonical_request_hash: "$canonical_request_hash
  credential_scope="${message_date}/${aws_region}/${aws_service}/aws4_request"
#  echo "credential_scope: $credential_scope"
  string_to_sign="$(printf "AWS4-HMAC-SHA256\n${message_time}\n${credential_scope}\n${canonical_request_hash}")"
#  echo "string_to_sign: $string_to_sign"
  signing_key="$($MKTEMP)"
  derive_string_key "${u_secret}" "${message_date}" "${aws_region}" "${aws_service}" > $signing_key
#  echo "signig_key: $(hex < $signing_key)"
  signature="$($MKTEMP)"
  hmac "$signing_key" "$string_to_sign" > $signature
  authorization_header="Authorization:AWS4-HMAC-SHA256 Credential=${u_key}/${credential_scope}, SignedHeaders=${header_list}, Signature=$( hex < $signature)"
#  echo "authorization_header: ${authorization_header}"
  rm -f $signing_key $signature

  # 何故かcurlを直接実行するとエラーが発生して実行できないので一度ファイルにコマンドを出力してから実行する
  LAST_ERROR_NO=0
  put_file="$($MKTEMP)"
  echo "#!/bin/sh\ncurl -Ssf -u yonezawa:tdc4331844 -k ${url} -X PUT -T '${upload_file}' -H '${authorization_header}' -H 'Content-Type:${aws_content_type}' -H 'Content-Length:${upload_file_size}' -H 'Host:${aws_host}' -H 'x-api-key:${aws_api_key}' -H 'x-amz-acl:${aws_acl}' -H 'x-amz-content-sha256:${upload_file_hash}' -H 'x-amz-Date:${message_time}' -o /dev/null -w %{http_code}" > ${put_file}
  chmod 777 ${put_file} 
  LAST_ERROR_NO=$(${put_file})
  rm -f ${put_file}

  echo "upload response: "${LAST_ERROR_NO}
  exit ${LAST_ERROR_NO}

