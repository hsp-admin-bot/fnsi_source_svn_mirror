DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-300010,-700010,-200010,-100010,-600010,-500010,-400010);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-300010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index = ''listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'Medicom', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-700010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index = ''listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC-iS(MegaOakiS) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-200010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index = ''listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-100010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index = ''listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1
		', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '富士通', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-600010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index = ''listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC標準(MegaOakHR) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-500010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index = ''listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'SSI 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index = ''listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
