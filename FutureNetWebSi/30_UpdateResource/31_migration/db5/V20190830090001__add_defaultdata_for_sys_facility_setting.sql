-- システム施設設定
delete from sys_facility_setting where facility_setting_no = '1006';

insert into sys_facility_setting (facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date)
  values
  ('1006', 'プレビューフラグ', '1', 3, '', '印刷', 1, '印刷時、プレビュー表示をする/しないの設定。（0：しない、1：する）\n　「1：する」に設定した場合、印刷を実行したときにプレビューを表示してから印刷を実行するかを選択できます。', 6, current_timestamp, current_timestamp )
;
