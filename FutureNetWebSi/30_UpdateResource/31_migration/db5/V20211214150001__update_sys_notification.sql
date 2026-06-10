-- 通知カテゴリ 40 治療スケジュール通知
DELETE FROM "sys_notification" WHERE "notification_no"  = 38;

-- 日次処理時指示内容変更通知を登録
INSERT INTO "sys_notification"("notification_no", "notification_category", "setting_name", "message", "additional_info", "disp_order", "available_keys", "is_disp", "is_del", "reg_date", "up_date", "help") VALUES (38, '40', '日次処理時指示内容変更通知', 
'日次処理によって変更になった指示があります。ご確認ください。
【患者ID】[HOSPPATID]
【患者名】[LASTNAME] [FIRSTNAME]
【透析予定日】[TREATDATE]
【治療方法】[TREATMENTNAME]', 
'{"FUNC": "004", "PATID": "[PATID]", "FACILITYCD": "[FACILITYCD]", "DATE": "[DATE]"}',
'26',
'[HOSPPATID]：院内患者ID、[LASTNAME]：患者名(姓)、[FIRSTNAME]：患者名(名)、[TREATDATE]：透析予定日、[TREATMENTNAME]：治療方法',
'1', '0', now(), now(),
'日次処理でスケジュール変更が発生した場合に通知します。');
