DELETE FROM sys_facility_setting WHERE facility_setting_no = '1066';
DELETE FROM sys_facility_setting WHERE facility_setting_no = '1067';

insert into sys_facility_setting (facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, system_use_disp, reg_date, up_date)  values ('1066', '担当者1未登録チェック', '1', '3', '', '治療状況リスト', '0', 'ONにすると治療記録の担当者1が未登録の場合に治療状況リスト大画面表示の画面下部ナビゲーションバーにベッド名を表示します。', 69, 2, current_timestamp, current_timestamp );
insert into sys_facility_setting (facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, system_use_disp, reg_date, up_date)  values ('1067', '担当者2未登録チェック', '1', '3', '', '治療状況リスト', '0', 'ONにすると治療記録の担当者2が未登録の場合に治療状況リスト大画面表示の画面下部ナビゲーションバーにベッド名を表示します。', 70, 2, current_timestamp, current_timestamp );
