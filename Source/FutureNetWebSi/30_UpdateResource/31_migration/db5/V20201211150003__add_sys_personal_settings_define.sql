-- 共通設定タブ定義へのデータ追加
insert into sys_personal_settings_define (
  personal_settings_cd,
  tab_define_cd,
  edit_level,
  item_info,
  combo_data,
  reference_combo_def,
  reg_date,
  up_date
) values (
  10,
  10,
  1,
  '{"item_info": []}',
  '{"combos": []}',
  '{"combos": []}',
  now(),
  now()
);
