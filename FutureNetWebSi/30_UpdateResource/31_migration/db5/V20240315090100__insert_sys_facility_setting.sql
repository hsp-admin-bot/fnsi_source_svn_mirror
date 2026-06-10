-- #10290 2024.03.15 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢
-- 施設設定：前体重許容範囲チェック有無
DELETE from ntss.sys_facility_setting where facility_setting_no = '1068';
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES('1068', '前体重許容範囲チェック', '1', 3, NULL, '体重計・条件送信', 0, '前体重測定後に前体重が目標体重からの許容範囲内にあるかどうかをチェックします。 ', 127, now(), now(), '2');
