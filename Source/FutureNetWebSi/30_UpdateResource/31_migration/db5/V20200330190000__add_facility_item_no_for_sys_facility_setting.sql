DELETE FROM sys_facility_setting WHERE facility_setting_no = '1030';

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
  1030,
  'カードログイン方式',
  1,
  4,
  '[{"id":"0","name":"0:無効"},{"id":"1","name":"1:手動"},{"id":"2","name":"2:自動"}]',
  'カードログイン方式',
  0,
  '手動：カードを置くとユーザーIDが入力され、パスワードを手動入力後にサインインボタンを押す。<br>自動：カードを置くだけで自動サインイン。',
  25,
  now(),
  now()
);
