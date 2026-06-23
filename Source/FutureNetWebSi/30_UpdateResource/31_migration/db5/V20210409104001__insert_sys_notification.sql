DELETE FROM "sys_notification" WHERE "notification_no"  = 37;

-- 帳票印刷失敗通知を登録
INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (37, 100, '帳票印刷失敗通知', '帳票印刷失敗しました。', '{}', '23', '', '1', '0', now(), now(), '帳票印刷失敗の通知');
