-- 個人設定タブ定義へのデータ追加
insert into mst_personal_tab_define (
  tab_define_cd,
  display_name,
  contents_id,
  disp_order,
  is_disp,
  is_del,
  reg_date,
  up_date,
  mode
) values (
  10,
  'デフォルト設定',
  'default-setting',
  7,
  1,
  0,
  now(),
  now(),
  2
);
