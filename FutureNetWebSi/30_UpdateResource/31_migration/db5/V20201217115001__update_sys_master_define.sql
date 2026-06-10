--定期点検項目グループマスタ   -    日常・定期点検項目グループマスタ
UPDATE ntss.sys_master_define	
SET master_name='日常・定期点検項目グループマスタ'
WHERE master_physical_name='mst_mainte_category';
