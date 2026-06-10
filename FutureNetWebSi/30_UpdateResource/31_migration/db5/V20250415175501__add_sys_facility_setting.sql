-- #11746 【因島：要望】体重計モードの場合に時間経過でのサインアウトをしない設定の追加
DELETE FROM sys_facility_setting WHERE facility_setting_no='3133';
INSERT INTO sys_facility_setting (facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES ('3133', '体重計モードの強制サインアウト','0',4,'[{"id":"0","name":"0:強制サインアウトする"},{"id":"1","name":"1:強制サインアウトしない"}]', '体重計・条件送信', 0, '体重計モードで一定時間後に強制サインアウトするかどうかを選択できます。<br>0:強制サインアウトする<br>1:強制サインアウトしない', 139, current_timestamp, current_timestamp, 2);
