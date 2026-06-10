DELETE FROM sys_signin_manager;
INSERT INTO sys_signin_manager
 (
    terminal_unique_string,
    facility_cd,
    user_id,
    reg_date,
    up_date
  )
values
  (
    'delete_test01',
    '009999',
    1000,
    '2020/05/27 15:00:00',
    '2020/05/27 15:05:00'
  ),
  (
    'delete_test02',
    '009999',
    1000,
    '2020/05/27 15:10:00',
    '2020/05/27 15:15:00'
  ),
  (
    'delete_test03',
    '009999',
    1000,
    '2020/05/27 15:20:00',
    '2020/05/27 15:25:00'
  );
