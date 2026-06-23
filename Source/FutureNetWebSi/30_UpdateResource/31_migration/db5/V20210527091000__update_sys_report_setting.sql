--紹介状の不正
DELETE FROM ntss.sys_report_setting WHERE function_cd = '03001';
INSERT INTO ntss.sys_report_setting
(function_cd, function_name, print_report_class, is_disp, is_del, reg_date, up_date, report_setting_no)
VALUES('03001', '紹介状', '[{"disp_status":"0","report_class":"2,3"},{"disp_status":"1","report_class":"2,9"}]'::json::json, '1', '0', '2020-12-12 09:30:00.000', '2020-12-12 09:30:00.000', 3001);
