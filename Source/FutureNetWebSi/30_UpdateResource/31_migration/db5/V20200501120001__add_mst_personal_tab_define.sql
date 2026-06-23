-- 個人設定タブ定義へのデータ追加
insert into mst_personal_tab_define(
  tab_define_cd,
  facility_cd,
  display_name,
  contents_id,
  disp_order,
  is_disp,
  is_del,
  reg_date,
  up_date,
  mode
) values (
  9,
  null,
  '定型文',
  'fixed-phrase',
  9,
  '1',
  '0',
  current_timestamp,
  current_timestamp,
  '2'
);
