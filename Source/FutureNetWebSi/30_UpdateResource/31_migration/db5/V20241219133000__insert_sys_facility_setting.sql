-- #11337 【たくしん会：改良】治療状況リストの日時表示のフォーマットを変更したい。
-- 治療状況 日時フォーマット 追加
DELETE from ntss.sys_facility_setting where facility_setting_no = '1069';
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES('1069', '日時フォーマット', '1', 4, '[{"id":"0","name":"0:YYYY/MM/DD hh:mm"},{"id":"1","name":"1:hh:mm"}]', '治療状況', 0, '日時項目のフォーマットを設定します。<br>0：YYYY/MM/DD hh:mm<br>1：hh:mm<br>デフォルト：1：hh:mm', 1, now(), now(), '2');
