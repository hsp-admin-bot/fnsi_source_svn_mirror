INSERT INTO sys_facility_setting ( 
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
VALUES (
  '1022',
  'ベッドコントロール',
  '0',
  3,
  '',
  'ベッドコントロール',
  0,
  '指示受け・承認機能はベッド・クールの移動の指示は本機能の対象外とするかどうか、設定します。',
  22,
  current_timestamp,
  current_timestamp
);
