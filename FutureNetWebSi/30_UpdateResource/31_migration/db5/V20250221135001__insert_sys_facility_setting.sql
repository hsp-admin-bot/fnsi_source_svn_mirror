-- #11095 時間経過での強制サインアウト修正
-- 治療状況マップの強制サインアウトON/OFF 追加
-- 治療状況リスト大画面の強制サインアウトON/OFF 追加
-- 治療状況リストの強制サインアウトON/OFF 追加
-- チェックリストの強制サインアウトON/OFF 追加
-- 遠隔監視の強制サインアウトON/OFF 追加
-- 治療状況リスト（大画面）の自動更新時間 追加
-- 遠隔監視の自動更新時間 追加
DELETE from ntss.sys_facility_setting where facility_setting_no = '3124';
DELETE from ntss.sys_facility_setting where facility_setting_no = '3125';
DELETE from ntss.sys_facility_setting where facility_setting_no = '3126';
DELETE from ntss.sys_facility_setting where facility_setting_no = '3127';
DELETE from ntss.sys_facility_setting where facility_setting_no = '3128';
DELETE from ntss.sys_facility_setting where facility_setting_no = '3129';
DELETE from ntss.sys_facility_setting where facility_setting_no = '3130';
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES ('3124', '治療状況マップ画面の自動更新サインアウト','0',4,'[{"id":"0","name":"0:自動サインアウトする"},{"id":"1","name":"1:自動サインアウトしない"}]', '治療状況マップ', 0, '治療状況マップ画面で自動更新のみで時間経過でした場合の自動サインアウトを設定します。<br>0:自動サインアウトする<br>1:自動サインアウトしない', 130, current_timestamp, current_timestamp, 3);
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES ('3125', '治療状況リスト大画面の自動更新サインアウト','0',4,'[{"id":"0","name":"0:自動サインアウトする"},{"id":"1","name":"1:自動サインアウトしない"}]', '治療状況リスト', 0, '治療状況リスト大画面で自動更新のみで時間経過でした場合の自動サインアウトを設定します。<br>0:自動サインアウトする<br>1:自動サインアウトしない', 131, current_timestamp, current_timestamp, 3);
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES ('3126', '治療状況リスト画面の自動更新サインアウト','0',4,'[{"id":"0","name":"0:自動サインアウトする"},{"id":"1","name":"1:自動サインアウトしない"}]', '治療状況リスト', 0, '治療状況リスト画面で自動更新のみで時間経過でした場合の自動サインアウトを設定します。<br>0:自動サインアウトする<br>1:自動サインアウトしない', 132, current_timestamp, current_timestamp, 3);
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES ('3127', 'チェックリスト画面の自動更新サインアウト','0',4,'[{"id":"0","name":"0:自動サインアウトする"},{"id":"1","name":"1:自動サインアウトしない"}]', 'チェックリスト', 0, 'チェックリスト画面で自動更新のみで時間経過でした場合の自動サインアウトを設定します。<br>0:自動サインアウトする<br>1:自動サインアウトしない', 133, current_timestamp, current_timestamp, 3);
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES ('3128', '遠隔監視画面の自動更新サインアウト','0',4,'[{"id":"0","name":"0:自動サインアウトする"},{"id":"1","name":"1:自動サインアウトしない"}]', '遠隔監視', 0, '遠隔監視画面で自動更新のみで時間経過でした場合の自動サインアウトを設定します。<br>0:自動サインアウトする<br>1:自動サインアウトしない', 134, current_timestamp, current_timestamp, 3);
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES ('3129', '治療状況リスト大画面の自動更新間隔 （秒）', '10', 2, '[{"min":"10",  "max":"99999999"}]', '治療状況リスト', 0, '治療状況リスト大画面の自動更新の間隔（秒）を設定します。', 135, current_timestamp, current_timestamp, 3);
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES ('3130', '遠隔監視の自動更新間隔 （秒）', '30', 2, '[{"min":"10",  "max":"99999999"}]', '遠隔監視', 0, '遠隔監視の自動更新の間隔（秒）を設定します。', 136, current_timestamp, current_timestamp, 3);
