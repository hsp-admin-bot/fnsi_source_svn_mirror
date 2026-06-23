-- システム設定
DELETE FROM sys_system_define WHERE ctl_no = 32;

insert into sys_system_define values (32, '003', 'データ削除処理時間設定', '{"startTime": "0500"}', '施設解約/期間外削除のスケジュール自動延長への割込み起動時間設定を行う。開始時刻をHHMM形式で指定する。
startTime: 処理開始時間', 1, current_timestamp);
