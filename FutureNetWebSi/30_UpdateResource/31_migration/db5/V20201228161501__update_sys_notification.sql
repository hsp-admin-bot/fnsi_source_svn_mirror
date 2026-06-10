DELETE FROM "sys_notification" WHERE "notification_category" = 60 and "notification_no" in (2,21,22,23,24);

INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (2, 60, '連携送信通知', '正しく連携されなかった情報があります。ご確認ください。
【患者番号】[HOSP_PAT_ID]
【患者名前】[LASTNAME] [FIRSTNAME]
【連携種別】[COOP_CD]
【対象日】[TARGET_DATE]', '{}', '2', '[HOSP_PAT_ID] : 患者番号、[LASTNAME]：患者名(姓)、[FIRSTNAME]：患者名(名)、[COOP_CD] : 連携種別、[TARGET_DATE] : 対象日', '1', '0', now(), now(), '画面から電子カルテへの送信通知。');

INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (21, 60, '連携受信通知', '【[COOP_CD]】電子カルテから受信の処理が失敗しました。', '{}', '21', '[COOP_CD] : 連携種別', '1', '0', now(), now(), '電子カルテから受信失敗すると通知します。');

INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (22, 60, '初回指示・浄化申込連携通知', '血液浄化申込情報を受信しました。', '{}', '22', '', '1', '0', now(), now(), '血液浄化申込情報受信の通知。');
INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (23, 60, '患者情報連携通知', '本日の透析スケジュール患者の情報更新を実施しました。', '{}', '23', '', '1', '0', now(), now(), '連携設定の患者定期更新の通知。');
INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (24, 60, '定時連携送信通知', '【[COOP_CD]】電子カルテへの定時一括送信が失敗しました。', '{}', '20', '[COOP_CD] : 連携種別', '1', '0', now(), now(), '定時処理における電子カルテへ送信失敗すると通知します。');
