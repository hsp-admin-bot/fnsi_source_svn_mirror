-- #12555 トースト通知表示時間の設定追加
DELETE FROM "sys_notification" WHERE "notification_no"  = 39;
-- トースト通知表示時間を登録
INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (39, 0, 'トースト通知表示時間', '', '{}', '1', '', '1', '0', now(), now(), '通知発生時のトースト表示時間を設定します。');
