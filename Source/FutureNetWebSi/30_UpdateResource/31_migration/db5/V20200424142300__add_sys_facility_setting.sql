insert into sys_facility_setting(
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
) values(
  '1046',
  '簡易検索対象条件',
  '0',
  2,
  '[{"min":"0", "max":"2"}]',
  '患者検索',
  0,
  '0：全患者対象に検索<br>1：死亡患者を除外して検索<br>2：死亡、転出、離脱、移植、拒否・不明を除外して検索',
  46,
  now(),
  now()
);