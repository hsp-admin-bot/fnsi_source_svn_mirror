DELETE FROM "sys_notification" WHERE "notification_no"  IN (23,25,28);

-- 連携通知のエラー発生時通知を登録
INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (28, 60, '連携エラー通知', 'エラー発生時通知                                       ', '{}', '20', '[COOP_CD] : 連携種別', '1', '0', now(), now(), 'エラー発生時通知');
--在宅機能の無効化
UPDATE sys_notification
SET
  setting_name = '検査結果ファイル取込処理結果通知',
  up_date = now()
WHERE notification_no = 26;
