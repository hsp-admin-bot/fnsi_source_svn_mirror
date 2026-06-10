DELETE FROM sys_facility_setting WHERE facility_setting_no = '1059';

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
  '1059',
  'パスワード有効期間（月）',
  3,
  2,
  '[{"min":"0",  "max":"999"}]',
  'サインイン',
  0,
  'パスワードの有効期間を月単位で設定します。<br>有効期間が過ぎた後はパスワードの変更が必要となります。<br>設定値を0とした場合、有効期間を無期限とします。',
  59,
  now(),
  now(),
  '3'
), (
  '1060',
  '過去パスワード再利用禁止（世代）',
  3,
  2,
  '[{"min":"0",  "max":"9"}]',
  'サインイン',
  0,
  '過去のパスワードを再利用禁止とする設定です。<br>何世代前までの再利用を禁止するか設定します。（最大9世代前まで）<br>設定値を0とした場合、過去のパスワードを再利用禁止しません。',
  60,
  now(),
  now(),
  '3'
);