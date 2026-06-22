truncate table mst_facility_setting;

--INSERT INTO mst_facility_setting
--(facility_cd, ctl_no, function_cd, name, value, description, is_editable, is_disp, is_del)
--VALUES
--('900001', 3, '00a', 'nameA', '35', 'descriptionA', '1', '1', '0')
--;


INSERT INTO mst_facility_setting
(facility_setting_no, facility_cd, value)
VALUES
('1001', '900001', 35)
;

truncate table sys_facility_setting;

INSERT INTO sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, system_use_disp)
VALUES
('1003', 'テストデータ3', '35', 2, '{  "min":"0,"  "max":"999"}', 'タイムアウト時間設定', 0, '施設毎のサインインタイムアウト時間設定。設定時間サーバとの通信がなかった場合、時間経過後サーバとの通信の時点でサインアウト画面へ遷移します。', 3, '3')
;