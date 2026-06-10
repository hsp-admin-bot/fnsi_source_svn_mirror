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
  system_use_disp,
  reg_date,
  up_date
)  values (
  '2001',
  'URLサインイン設定',
  '0',
  '4',
  '[{"id":"0","name":"0:使用しない"},{"id":"1","name":"1:利用者ID＋秘密鍵"},{"id":"2","name":"2:利用者ID＋パスワード"},{"id":"3","name":"3:利用者ID"}]',
  'サインイン',
  '0',
  'URLに設定した情報を所定のフォーマットで付加することで自動でサインインします。<br>※クラウド使用時はセキュリティレベルが低くなるため本設定の使用を推奨しません。',
  66,
  3,
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
  system_use_disp,
  reg_date,
  up_date
)  values (
  '2002',
  'URLサインイン秘密鍵',
  null,
  '1',
  '',
  'サインイン',
  '0',
  'URLサインイン設定で「1：利用者ID＋秘密鍵」を設定した場合の秘密鍵を設定します。<br>8文字以上の複雑な文字列で登録してください。',
  67,
  3,
  current_timestamp,
  current_timestamp );

