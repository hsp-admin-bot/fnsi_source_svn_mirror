-- V1.1B(0003)のレコードのrelease_dateに20250822にアップデート
-- 「FutureNetWeb+Si：V1.1B(0003)」のリリース日更新
UPDATE ntss.sys_release_info SET release_date = '20250822', up_date = now() WHERE title = 'FutureNetWeb+Si：V1.1B(0003)';

-- V1.1C(0004)、release_dateが20251205のレコードをinsert
-- 「FutureNetWeb+Si：V1.1C(0004)」を条件に削除
DELETE FROM ntss.sys_release_info WHERE title = 'FutureNetWeb+Si：V1.1C(0004)';
-- FutureNetWeb+Si：V1.1C(0004) 追加
INSERT INTO ntss.sys_release_info (release_date,title,system_type,path_url,is_disp,is_del,reg_date,up_date) VALUES
	 ('20251205','FutureNetWeb+Si：V1.1C(0004)','2',null,'1','0',now(),now());
