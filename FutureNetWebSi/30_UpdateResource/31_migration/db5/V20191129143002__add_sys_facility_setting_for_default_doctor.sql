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
  '1025',
  'デフォルト選択医師設定',
  '0',
  9,
  '',
  'デフォルト選択医師',
  0,
  '各機能のデフォルト選択医師を指定します。<br>デフォルトを未指定にしたい場合には空の設定値で登録してください。',
  25,
  current_timestamp,
  current_timestamp
);
