DELETE FROM "sys_notification" WHERE "notification_no" in (25, 26, 27);

--V20201124100425__add_nodification_config_for_sys_notification.sql
-- 修正内容：檢查結果通知
INSERT INTO "ntss"."sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (25, 80, '検査通知', '患者[LASTNAME] [FIRSTNAME]検査が完了しました', '{"FUNC": "0181", "PATID": "[PATID]"}', '1', '[LASTNAME]：患者名(姓)、[FIRSTNAME]：患者名(名))、[PATID]：内部患者ID', '1', '0', '2020-09-16 14:09:38', '2020-09-16 14:09:40', '患者検査通知');

--V20201218104301__add_nodification_config_for_sys_notification.sql
-- 修正内容：患者検査結果ファイル取り込み通知

--V20201224130101__insert_sys_notification.sql
INSERT INTO "ntss"."sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (26, 80, 'ファイル取り込み通知', 'ファイル取り込みが完了しました。ご確認ください。
【成功件数】[SUCCESSFULCOUNT]
【失敗件数】[FAILEDCOUNT]
【更新日時】[UP_DATE]', '{"FUNC": "018", "FACILITYCD": "[FACILITYCD]"}', '1',  '1', '0', '2020-09-16 14:09:38', '2020-09-16 14:09:40', '患者検査結果ファイル取り込み通知');

--V20201124100418__add_nodification_config_for_sys_notification.sql
-- 修正内容：画面遷移時通知既読
INSERT INTO "ntss"."sys_notification" ("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES ('27', '0', '画面遷移時通知既読', '画面遷移時通知既読', '{}', '0', ' ', '1', '0', '2020-09-07 11:23:20', '2020-09-07 11:23:23', '画面遷移時通知既読');
