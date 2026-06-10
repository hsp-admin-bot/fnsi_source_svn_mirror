DELETE FROM ntss.sys_report_setting WHERE function_cd = '02101';
INSERT INTO "ntss"."sys_report_setting" ("function_cd", "function_name", "print_report_class", "is_disp", "is_del", "reg_date", "up_date", "report_setting_no") VALUES ('02101', '検査依頼', '[{"disp_status":"0","report_class":"3,4,5,6,8,11"},{"disp_status":"1","report_class":"1,2,8,9,10"},{"disp_status":"2","report_class":"3,4,5,6,8,11"}]', '1', '0', '2020-12-12 09:30:00', CURRENT_TIMESTAMP, 2101);

