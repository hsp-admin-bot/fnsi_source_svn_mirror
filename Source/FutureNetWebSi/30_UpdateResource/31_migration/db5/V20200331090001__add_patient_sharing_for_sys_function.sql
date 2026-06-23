
-- sys_function にデータ追加
insert into sys_function (
  function_cd,
  function_name,
  is_disp,
  is_del,
  reg_date,
  up_date
) values (
  '036',
  '患者情報共有',
  1,
  0,
  current_timestamp,
  current_timestamp
);
