-- V1.1B(0003)リリース情報
-- 「FutureNetWeb+Si：V1.1B(0002)」を条件に削除
DELETE FROM ntss.sys_release_info WHERE title = 'FutureNetWeb+Si：V1.1B(0002)';
-- FutureNetWeb+Si：V1.1B(0003) 追加
INSERT INTO ntss.sys_release_info (release_date,title,system_type,path_url,is_disp,is_del,reg_date,up_date) VALUES
	 (null,'FutureNetWeb+Si：V1.1B(0003)','2',null,'1','0',now(),now());
