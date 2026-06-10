DELETE FROM "sys_notification" WHERE "notification_no"  = 37;

-- 帳票印刷失敗通知を登録
INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (37, 100, '帳票印刷失敗通知', 
'帳票印刷が失敗しました。ご確認ください。
【帳票種別】[REPORTTYPE]
【帳票名】[REPORTNAME]
【失敗日時】[UP_DATE]', 
'{}', '23', '', '1', '0', now(), now(), '帳票印刷失敗の通知');
