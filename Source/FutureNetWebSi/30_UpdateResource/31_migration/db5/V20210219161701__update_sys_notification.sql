DELETE FROM "sys_notification" WHERE "notification_no" in (25);

--V20201124100425__add_nodification_config_for_sys_notification.sql
-- 修正内容：檢査結果通知
INSERT INTO "ntss"."sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (25, 80, '検査通知', '患者[LASTNAME] [FIRSTNAME]検査が完了しました', '{"FUNC": "0181", "PATID": "[PATID]"}', '1', '[LASTNAME]：患者名(姓)、[FIRSTNAME]：患者名(名))、[PATID]：内部患者ID', '1', '0', '2020-09-16 14:09:38', '2020-09-16 14:09:40', '患者検査通知');