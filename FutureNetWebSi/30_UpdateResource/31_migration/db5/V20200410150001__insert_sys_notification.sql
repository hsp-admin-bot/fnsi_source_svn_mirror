-- 新規患者登録時の通知定義を登録
INSERT INTO sys_notification(
  notification_no,
  notification_category, 
  setting_name, 
  message, 
  additional_info, 
  disp_order, 
  available_keys, 
  is_disp, 
  is_del, 
  reg_date, 
  up_date
)
VALUES(
  1,
  '10',
  '新規患者登録通知',
  '新規患者[LASTNAME] [FIRSTNAME]が登録されました。',
  '{"FUNC": "007", "PATID": "[PATID]", "FACILITYCD": "[FACILITYCD]"}',
  '1',
  '[LASTNAME]：患者名(姓)、[FIRSTNAME]：患者名(名)、[PATID]：内部患者ID、[FACILITYCD]：施設コード',
  '1',
  '0',
  now(),
  now()
);
