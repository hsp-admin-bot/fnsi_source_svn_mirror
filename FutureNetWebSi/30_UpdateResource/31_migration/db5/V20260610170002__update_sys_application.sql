DELETE FROM "ntss"."sys_application" WHERE application_name = '2025年度JSDT統計調査アプリ';
INSERT INTO "ntss"."sys_application" ("application_name", "version", "path", "disp_order", "reg_date", "up_date", "is_disp", "is_del") VALUES ('2025年度JSDT統計調査アプリ', '2.0.0.9', '/application/download/StatisticsSetup.msi', 6, '2025-12-12 09:49:22.057', CURRENT_TIMESTAMP, '1', '0');
