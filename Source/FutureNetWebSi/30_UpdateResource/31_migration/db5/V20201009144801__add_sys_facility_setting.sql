delete from sys_facility_setting where facility_setting_no = '1065';
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
  system_use_disp,
  reg_date,
  up_date
)  values (
  '1065',
  '大画面表示のお知らせ内容',
  '-1',
  '5',
  '[{"master_physical_name":"mst_bbs_kind"}]',
  '治療状況リスト',
  '0',
  '治療状況リスト大画面のお知らせ欄に表示する施設イベントカテゴリを１つ指定します。',
  65,
  2,
  current_timestamp,
  current_timestamp );
