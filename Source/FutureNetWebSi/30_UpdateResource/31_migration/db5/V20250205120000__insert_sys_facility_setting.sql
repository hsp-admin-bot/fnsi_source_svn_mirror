-- 治療記録 愁訴処置内の投与薬剤表示 追加
DELETE from ntss.sys_facility_setting where facility_setting_no = '1070';
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES('1070', '愁訴処置内の投与薬剤表示', '0', 3, '', '治療記録', 0, '治療記録の愁訴処置画面に投与済み投与薬剤の表示を設定します。<br>OFF：非表示、ON：表示', 129, now(), now(), '2');
