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
    'term1',
    '009999',
    1,
    '2020/05/27 15:00:00',
    '2020/05/27 15:05:00'
  ),
  (
    'term2',
    '009999',
    2,
    '2020/05/27 15:10:00',
    '2020/05/27 15:15:00'
  ),
  (
    'term3',
    '009999',
    3,
    '2020/05/27 15:20:00',
    '2020/05/27 15:25:00'
  ),
  -- term4は登録のテストで使用している為、空き番とする.
  (
    'term5',
    '123456',
    2,
    '2020/05/27 15:30:00',
    '2020/05/27 15:35:00'
  );
