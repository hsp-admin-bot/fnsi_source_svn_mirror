-- #12398 体重計モードで体重計測定記録に遷移可能とする
-- 体重計モードで体重計測定記録画面に遷移可能な測定記録ボタンの表示/非表示を設定する施設管理番号を追加
DELETE FROM ntss.sys_facility_setting WHERE facility_setting_no = '3139';

INSERT INTO ntss.sys_facility_setting (facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp) 
VALUES ('3139', '体重計モード測定記録ボタン表示切替', '0', 4, '[{"id":"0","name":"0：表示しない"},{"id":"1","name":"1：表示する"}]', '体重計・条件送信', 0, '体重計モードで体重計測定記録画面に遷移可能なボタンの表示/非表示を設定します。<br>0：表示しない<br>1：表示する', 147, current_timestamp, current_timestamp, '2');
