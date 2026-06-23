DELETE FROM "ntss"."sys_report_class" where report_class_cd in (10);
INSERT INTO "ntss"."sys_report_class" ("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (10, '単一集計', '[]', '1', '0', CURRENT_TIMESTAMP, '2021-05-17 18:53:21');
