DELETE FROM sys_facility_setting WHERE facility_setting_no = '1064';

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
  '1064',
  '権限変更時サインアウト',
  0,
  4,
  '[{"id":"0","name":"0:無効"},{"id":"1","name":"1:有効"}]',
  '利用者マスタ',
  0,
  '有効にすると、利用者マスタでの編集権限変更や、使用機能設定で機能の削除が行われた場合に、変更された利用者を強制サインアウトさせます。<br>無効の場合は、次回サインイン時に設定が反映されます。',
  64,
  now(),
  now(),
  '3'
);
