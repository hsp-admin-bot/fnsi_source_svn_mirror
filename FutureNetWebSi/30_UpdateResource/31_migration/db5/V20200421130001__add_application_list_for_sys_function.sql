
-- sys_function にデータ追加
insert into sys_function (
  function_cd,
  function_name,
  is_disp,
  is_del,
  reg_date,
  up_date,
  disp_order,
  target_facility
) values (
  '038',
  '申込一覧',
  1,
  0,
  current_timestamp,
  current_timestamp,
  0,
  NULL
);
