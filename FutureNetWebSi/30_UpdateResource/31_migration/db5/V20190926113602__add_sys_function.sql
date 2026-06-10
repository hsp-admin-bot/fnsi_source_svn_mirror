-- sys_function にデータ追加
insert into sys_function (
  function_cd,
  function_name,
  is_disp,
  is_del,
  reg_date,
  up_date
) values (
  '021',
  '検査依頼',
  1,
  0,
  current_timestamp,
  current_timestamp
);
insert into sys_function (
  function_cd,
  function_name,
  is_disp,
  is_del,
  reg_date,
  up_date
) values (
  '022',
  '放射線検査依頼',
  1,
  0,
  current_timestamp,
  current_timestamp
);
