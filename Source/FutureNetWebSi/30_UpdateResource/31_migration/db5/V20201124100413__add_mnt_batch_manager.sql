-- バッチ稼働状況管理
DELETE FROM mnt_batch_manager WHERE ctl_no in (3, 4);
INSERT INTO mnt_batch_manager (ctl_no, batch_name, division, status, description, start_time, end_time, reg_date, up_date) VALUES
(3,'ログイン無効化','3','0','日次で2時に起動',NULL,NULL,'2020/05/28 8:44:06','2020/05/28 8:44:06'),
(4,'データ削除','1','0','日次で2時に起動',NULL,NULL,'2020/05/28 8:44:06','2020/05/28 8:44:06');