-- ログダウンロード、path_temp_zipを追加する
update sys_system_define set value='{"path_output": "/efs", "path_temp_zip": "/opt/fnsi/cache/view-log/"}' where ctl_no = 1000