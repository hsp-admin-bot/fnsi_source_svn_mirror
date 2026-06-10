-- #11609 V1.1Aリリース情報、取説追加
-- FutureNetWeb+Si：V1.1A(0023) 追加
INSERT INTO ntss.sys_release_info (release_date,title,system_type,path_url,is_disp,is_del,reg_date,up_date) VALUES
	 (null,'FutureNetWeb+Si：V1.1A(0023)','2',null,'1','0',now(),now());
-- FutureNetWeb+Si：V1.0A(0054) リリース日更新
-- FutureNetWeb+Si：V1.0B(0002) リリース日更新
UPDATE ntss.sys_release_info SET release_date = '20241118', up_date = now() WHERE title = 'FutureNetWeb+Si：V1.0A(0054)';
UPDATE ntss.sys_release_info SET release_date = '20250123', up_date = now() WHERE title = 'FutureNetWeb+Si：V1.0B(0002)';
