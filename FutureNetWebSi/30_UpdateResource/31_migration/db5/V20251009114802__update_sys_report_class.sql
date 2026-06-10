DELETE FROM "ntss"."sys_report_class" where report_class_cd in (7);
INSERT INTO "ntss"."sys_report_class" ("report_class_cd", "report_class_name", "report_type", "is_disp", "is_del", "up_date", "reg_date") VALUES (7, '装置帳票', '[{"cd": "1", "name": "汎用帳票"}, {"cd": "0", "name": "固定帳票専用"}]', '1', '0', CURRENT_TIMESTAMP, '2021-05-17 18:49:57');
