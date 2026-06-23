-- #11747 【因島：改良】治療状況マップのインジケータの表示
-- 治療状況マップ＞治療状況用、治療状況マップ＞スケジュール用の設定を追加
DELETE from ntss.sys_facility_setting where facility_setting_no = '1071';
DELETE from ntss.sys_facility_setting where facility_setting_no = '1072';
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES('1071', '治療状況のインジケータ表示設定', '["0","1","2"]', 7, '[{"id":"0","name":"0：工程"},{"id":"1","name":"1：警報・報知"},{"id":"2","name":"2：指示変更"}]', '治療状況マップ', 0, '治療状況マップ画面の治療状況でベッド内インジケータとして表示する対象を設定します。選択していない項目は表示しません。', 140, now(), now(), '2');
INSERT INTO ntss.sys_facility_setting
(facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp)
VALUES('1072', 'スケジュールのインジケータ表示設定', '["0","1","2","3","4","5","6","7"]', 7, '[{"id":"0","name":"0：工程"},{"id":"1","name":"1：入外区分"},{"id":"2","name":"2：感染症不一致"},{"id":"3","name":"3：VA方向不一致"},{"id":"4","name":"4：治療方法不一致"},{"id":"5","name":"5：患者イベント有無"},{"id":"6","name":"6：検査予定有無"},{"id":"7","name":"7：一般撮影検査予定有無"}]', '治療状況マップ', 0, '治療状況マップ画面のスケジュールでベッド内インジケータとして表示する対象を設定します。選択していない項目は表示しません。', 141, now(), now(), '2');
