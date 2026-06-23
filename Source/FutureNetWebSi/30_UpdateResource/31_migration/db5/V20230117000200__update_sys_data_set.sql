delete from "sys_data_set" where "sql_cd" in (-102, -99);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99, 'select 
	pod.save_1->>''key_01'' as key_01,
	pod.save_1->>''key_02'' as key_02,
	pod.save_1->>''key_03'' as key_03,
	pod.save_1->>''key_04'' as key_04,
	pod.save_1->>''key_05'' as key_05,
	pod.save_1->>''key_06'' as key_06,
	pod.save_1->>''key_07'' as key_07,
	pod.save_1->>''key_08'' as key_08,
	pod.save_1->>''key_09'' as key_09,
	pod.save_1->>''key_10'' as key_10
from 
	pat_coop_detail pod
where
	pat_id = @patId
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND coop_version = @coopVersion
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end', 2, '[{}]', '0', '{"applications": [4]}', NULL, '患者情報退避', '2020-04-06 18:22:01.42', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-102, 'select
	pcd.save_1->>''key_01'' as param01,
	pcd.save_1->>''key_02'' as param02,
	pcd.save_1->>''key_03'' as param03,
	pcd.save_1->>''key_04'' as param04,
	pcd.save_1->>''key_05'' as param05,
	pcd.save_1->>''key_06'' as param06,
	pcd.save_1->>''key_07'' as param07,
	pcd.save_1->>''key_08'' as param08,
	pcd.save_1->>''key_09'' as param09,
	pcd.save_1->>''key_10'' as param10,
	pcd.save_2->>''key_01'' as param11,
	pcd.save_2->>''key_02'' as param12,
	pcd.save_2->>''key_03'' as param13,
	pcd.save_2->>''key_04'' as param14,
	pcd.save_2->>''key_05'' as param15,
	pcd.save_2->>''key_06'' as param16,
	pcd.save_2->>''key_07'' as param17,
	pcd.save_2->>''key_08'' as param18,
	pcd.save_2->>''key_09'' as param19,
	pcd.save_2->>''key_10'' as param20
from
	pat_coop_detail pcd
where
	pcd.pat_id = @patId
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND coop_version = @coopVersion
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）患者補完情報20個', '2020-05-01 09:43:15.82', CURRENT_TIMESTAMP, NULL);
