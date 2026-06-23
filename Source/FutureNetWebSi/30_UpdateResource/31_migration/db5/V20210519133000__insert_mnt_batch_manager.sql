-- バッチ稼働状況管理
DELETE FROM mnt_batch_manager WHERE ctl_no in (5);
INSERT INTO mnt_batch_manager (ctl_no, batch_name, division, status, description, start_time, end_time, reg_date, up_date) VALUES
(5,'検査結果再計算','1','0','日次で2時に起動',NULL,NULL,current_timestamp,current_timestamp)