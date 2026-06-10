DELETE FROM ntss.mst_if_edge_command
WHERE ctl_no=13;

INSERT INTO ntss.mst_if_edge_command
(ctl_no, command_key, command, add_setting, is_del, reg_date, up_date, processing, processing_detail)
VALUES(13, 'viewLogUpLoad', 'bash -c ''
CONF=/etc/sysconfig/ntss
HOST=$(awk -F= ''"''"''/^NTSS_VIEW_SOCKET_CLIENT_HOST=/{gsub(/"/,"",$2);print $2}''"''"'' "$CONF")
PORT=$(awk -F= ''"''"''/^NTSS_VIEW_SOCKET_CLIENT_LOG_SEND_PORT=/{gsub(/"/,"",$2);print $2}''"''"'' "$CONF")
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  PORT=7014
fi
printf "logUpload\n" > /dev/tcp/$HOST/$PORT
''', '0', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'VIEWのログアップロード', 'VIEWのログアップロードをする');