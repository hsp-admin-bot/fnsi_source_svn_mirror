--装置設定 DP=Qd+Qs(補液速度加算)表示切替え
INSERT INTO sys_facility_setting(
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
  up_date,
  system_use_disp
) VALUES (
  '3010',
  'DP=Qd+Qs(補液速度加算)表示切替え',
  '0',
  3,
  '',
  '装置設定',
  0,
  '操作範囲詳細画面の「DP=Qd+Qs(補液速度加算)」表示設定 0：非表示、1：表示',
  110,
  now(),
  now(),
  '3'
);