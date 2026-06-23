-- システム設定
DELETE FROM sys_system_define Where ctl_no = 13;

insert into sys_system_define values (13, '003', '日次バッチ処理設定', '{"startTime": "0000", "endTime": "2359"}', '日次バッチ処理の設定を行う。開始時刻、終了時刻をHHMM形式で指定する', '1', current_timestamp);
