-- V1.1A(0033)のレコードのrelease_dateに20250716にアップデート
-- 「FutureNetWeb+Si：V1.1A(0033)」のリリース日更新
UPDATE ntss.sys_release_info SET release_date = '20250716', up_date = now() WHERE title = 'FutureNetWeb+Si：V1.1A(0033)';

-- V1.1B(0002)、release_dateがnullのレコードをinsert
-- 「FutureNetWeb+Si：V1.1B(0002)」を条件に削除
DELETE FROM ntss.sys_release_info WHERE title = 'FutureNetWeb+Si：V1.1B(0002)';
-- FutureNetWeb+Si：V1.1B(0002) 追加
INSERT INTO ntss.sys_release_info (release_date,title,system_type,path_url,is_disp,is_del,reg_date,up_date) VALUES
	 (null,'FutureNetWeb+Si：V1.1B(0002)','2',null,'1','0',now(),now());
