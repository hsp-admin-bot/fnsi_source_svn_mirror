-- システム設定
-- mnt_notification_messageに関する定義を追加
DELETE FROM sys_system_define WHERE ctl_no in (31, 33);

insert into sys_system_define values (31, '003', '期間外削除テーブル管理(ReMSのみ施設)', '[{"db_class": 2, "table_name": "mni_monitor", "time_column_name": "up_date", "retention_period": 12, "exception": {}},{"db_class": 2, "table_name": "mnt_gathering_manage", "time_column_name": "up_date", "retention_period": 12, "exception": {}},{"db_class": 2, "table_name": "mnt_motion_record", "time_column_name": "up_date", "retention_period": 12, "exception": {}},{"db_class": 2, "table_name": "mnt_notification_message", "time_column_name": "up_date", "retention_period": 3, "exception": {}}]', '期間削除で対象とするテーブルを指定する
db_class: 対象のDBクラス
table_name: 期間外削除の対象テーブル名
time_column_name: 期間外の判断基準とするTimeStampのカラム
retention_period：データ保持期間：単位は月
exception：例外施設の指定、例外期間0は削除しない
　凡例：
　　{
　　　例外期間1(月) : [施設コード1,施設コード2,…],
　　　例外期間2(月) : [施設コード3,施設コード4,…],
　　}', 1, current_timestamp);

insert into sys_system_define values (33, '003', '期間外削除テーブル管理(FNSi含む施設)', '[{"db_class": 2, "table_name": "mnt_notification_message", "time_column_name": "up_date", "retention_period": 3, "exception": {}}]', '期間削除で対象とするテーブルを指定する
db_class: 対象のDBクラス
table_name: 期間外削除の対象テーブル名
time_column_name: 期間外の判断基準とするTimeStampのカラム
retention_period：データ保持期間：単位は月
exception：例外施設の指定、例外期間0は削除しない
　凡例：
　　{
　　　例外期間1(月) : [施設コード1,施設コード2,…],
　　　例外期間2(月) : [施設コード3,施設コード4,…],
　　}', 1, current_timestamp);
