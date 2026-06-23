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
  '1033',
  'チェックリスト自動更新間隔 （分）',
  '3',
  2,
  '[{"min":"1","max":"99"}]',
  'チェックリスト',
  0,
  'チェックリストの自動更新を有効にした際の更新間隔（分）を設定します。',
  33,
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
  '1034',
  '体重計選択有効化設定',
  '0',
  4,
  '[{"id":"0","name":"0:無効"},{"id":"1","name":"1:有効"}]',
  '体重計・条件送信',
  0,
  '体重測定・条件送信画面での体重計選択の有効/無効を切り替えます。<br>
0：無効<br>
1：有効<br>
【注意】有効化すると、離れた場所や同じ体重計を複数の画面で測定値の受信が可能となります。<br>
患者取り違えや重複条件送信などの発生にご注意の上、ご使用ください。',
  34,
  current_timestamp,
  current_timestamp
);
