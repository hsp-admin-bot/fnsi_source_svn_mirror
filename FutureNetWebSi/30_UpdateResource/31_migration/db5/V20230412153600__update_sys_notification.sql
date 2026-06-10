DELETE FROM "ntss"."sys_notification" WHERE notification_no IN (21);
INSERT INTO "ntss"."sys_notification" ("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (21, 60, '連携受信通知', '【[COOP_CD]】[TITLE][HOSPPATID]電子カルテから受信の処理が失敗しました。', '{}', '21', '[COOP_CD] : 連携種別 [TITLE]:タイトル [HOSPPATID]：院内患者ID', '1', '0', '2021-03-15 10:41:50.017', CURRENT_TIMESTAMP, '電子カルテから受信失敗すると通知します。');

