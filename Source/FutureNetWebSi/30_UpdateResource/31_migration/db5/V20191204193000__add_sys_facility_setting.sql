INSERT INTO sys_facility_setting
  (
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
  ) VALUES (
  '1026',
  '前体重時車いす測定順序',
  '1',
  4,
  '[{"id":"1","name":"1:体重＋車いす→車いす"},{"id":"2","name":"2:車いす→体重＋車いす"}]',
  '前体重時車いす測定順序',
  0,
  '未登録車いすを使用する患者の前体重測定順序を設定します。',
  26,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP );

INSERT INTO sys_facility_setting
  (
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
  ) VALUES (
  '1027',
  '後体重時車いす測定順序',
  '1',
  4,
  '[{"id":"1","name":"1:体重＋車いす→車いす"},{"id":"2","name":"2:車いす→体重＋車いす"}]' ,
  '後体重時車いす測定順序',
  0,
  '未登録車いすを使用する患者の後体重測定順序を設定します。' ,
  27,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP );