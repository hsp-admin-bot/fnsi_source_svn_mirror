--add 3020,実施者選択

INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES('3020', 'デフォルト選択実施者', '0', 9, '', '実施者選択', 0, '各機能の医師選択項目で初期選択される医師を指定します。未指定にしたい場合には空の設定値で登録してください。', 120, '2021-01-25 10:11:36.331', '2021-01-25 10:11:36.331', '2');
