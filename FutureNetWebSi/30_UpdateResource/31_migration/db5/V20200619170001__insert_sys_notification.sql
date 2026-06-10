DELETE FROM sys_notification WHERE notification_no = 2;

-- 連携通知の通知定義を登録
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
  2,
  '60',
  '連携通知',
  '正しく連携されなかった情報があります。ご確認ください。
【患者番号】[HOSP_PAT_ID]
【連携種別】[COOP_CD]
【更新日時】[UP_DATE]
【対象日】[TARGET_DATE]		
【区分】[CATEGORY]',
  '{"PAT_ID": "[PAT_ID]", "FACILITY_CD": "[FACILITY_CD]"}',
  '2',
  '[HOSP_PAT_ID] : 患者番号、[COOP_CD] : 連携種別、[UP_DATE] : 更新日時、[TARGET_DATE] : 対象日、[CATEGORY] : 区分、[PAT_ID]：内部患者ID、[FACILITY_CD]：施設コード',
  '1',
  '0',
  now(),
  now()
);