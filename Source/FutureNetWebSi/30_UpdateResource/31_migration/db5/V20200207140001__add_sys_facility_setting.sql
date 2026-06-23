insert into sys_facility_setting (
  facility_setting_no, 
  setting_name, 
  default_value, 
  input_type, 
  option_value, 
  function_name, 
  maker_setting, 
  description, 
  disp_order, 
  reg_date, 
  up_date
)
values (
  '1031', 
  '延長処理開始時刻', 
  '0000', 
  1, 
  '', 
  'スケジュール延長', 
  0, 
  'スケジュール自動延長処理を行う時間帯の範囲（開始）を設定します（時分指定）。',
  31, 
  current_timestamp, 
  current_timestamp );

insert into sys_facility_setting (
  facility_setting_no, 
  setting_name, 
  default_value, 
  input_type, 
  option_value, 
  function_name, 
  maker_setting, 
  description, 
  disp_order, 
  reg_date, 
  up_date
)
values (
  '1032', 
  '延長処理終了時刻', 
  '2359', 
  1, 
  '', 
  'スケジュール延長', 
  0, 
  'スケジュール自動延長処理を行う時間帯の範囲（終了）を設定します（時分指定）。', 
  32, 
  current_timestamp, 
  current_timestamp 
);
