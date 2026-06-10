
-- sys_function にデータ追加
insert into sys_function (
  function_cd,
  function_name,
  is_disp,
  is_del,
  reg_date,
  up_date
) values (
  '025',
  '在宅透析',
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
  '026',
  '在宅透析患者用',
  1,
  0,
  current_timestamp,
  current_timestamp
);
