-- sys_function にデータ追加
insert into sys_function (
  function_cd,
  function_name,
  is_disp,
  is_del,
  reg_date,
  up_date
) values (
  '033',
  '定期点検',
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
  '034',
  '日常点検',
  1,
  0,
  current_timestamp,
  current_timestamp
);
