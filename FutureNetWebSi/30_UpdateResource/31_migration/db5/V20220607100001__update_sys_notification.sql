DELETE FROM "sys_notification" WHERE "notification_category" = 60 and "notification_no" in (23);

INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (23, 60, '患者情報連携通知', '本日の透析スケジュール患者の情報更新を実施しました。', '{}', '23', '', '1', '0', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '連携設定の患者定期更新の通知。');
