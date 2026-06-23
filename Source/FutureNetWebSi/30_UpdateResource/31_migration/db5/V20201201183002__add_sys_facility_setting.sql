--患者経過総合ビューア 医療材料表示順
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
  '3006',
  '医療材料表示順',
  '0',
  4,
  '[{"id":"0","name":"0：登録順"},{"id":"1","name":"1：分類名称コード"},{"id":"2","name":"2：医療材料マスタ表示順"}]',
  '患者経過総合ビューア',
  0,
  '指定した値を元に医療材料の表示順を設定します。同一の値を持つ場合、マストセレクタ順（医療材料マスタの登録順）になります。',
  106,
  now(),
  now(),
  '3'
);
--患者経過総合ビューア 投与薬剤表示順
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
  '3007',
  '投与薬剤表示順',
  '0',
  4,
  '[{"id":"0","name":"0：登録順"},{"id":"1","name":"1：分類名称コード"},{"id":"2","name":"2：薬剤区分（通常薬剤＞セット薬剤(調整薬剤)）"},{"id":"3","name":"3：薬剤マスタ表示順"},{"id":"4","name":"4：投与時間帯"},{"id":"5","name":"5：手技"},{"id":"6","name":"6：投薬パターンコード"}]',
  '患者経過総合ビューア',
  0,
  '指定した値を元に投与薬剤の表示順を設定します。同一の値を持つ場合、マストセレクタ順（薬剤マスタの登録順）になります。',
  107,
  now(),
  now(),
  '3'
);
