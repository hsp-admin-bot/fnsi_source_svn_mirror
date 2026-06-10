--体重測定・条件送信 マスタ削除発生時条件送信設定
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
  '3018',
  'マスタ削除発生時条件送信設定',
  '0',
  4,
  '[{"id":"0","name":"0:送信不可"},{"id":"1","name":"1:送信可能"}]',
  '体重測定・条件送信',
  0,
  '薬剤、医療材料、ダイアライザ、VAがマスタ削除を発生した場合、条件送信の不可／可能を切り替えます。',
  118,
  now(),
  now(),
  '3'
);
--体重測定・条件送信 マスタ期限切れ発生時条件送信設定
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
  '3019',
  'マスタ期限切れ発生時条件送信設定',
  '0',
  4,
  '[{"id":"0","name":"0:送信不可"},{"id":"1","name":"1:送信可能"}]',
  '体重測定・条件送信',
  0,
  '薬剤、医療材料、ダイアライザ、VAがマスタ期限切れを発生した場合、条件送信の不可／可能を切り替えます。',
  119,
  now(),
  now(),
  '3'
);