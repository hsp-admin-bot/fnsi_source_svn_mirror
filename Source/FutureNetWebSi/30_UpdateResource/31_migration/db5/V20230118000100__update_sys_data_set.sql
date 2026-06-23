delete from "sys_data_set" where sql_cd in (-700010,-600010,-500010,-400010,-300010,-200010,-100010,-63);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-700010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
	AND mcd.coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index like ''%listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC-iS(MegaOakiS) 透析レポート', '2022-04-04 16:37:06.785', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-600010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
	AND mcd.coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index like ''%listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC標準(MegaOakHR) 透析レポート', '2022-04-04 16:37:06.785', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-500010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
	AND mcd.coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index like ''%listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'SSI 透析レポート', '2022-04-04 16:37:06.785', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
	AND mcd.coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index like ''%listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', '2022-04-04 16:37:06.785', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-300010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
	AND mcd.coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index like ''%listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'Medicom', '2022-04-04 16:37:06.785', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-200010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
	AND mcd.coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index like ''%listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI', '2022-04-04 16:37:06.785', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-100010, 'SELECT 
1 AS order_no
,COALESCE( ( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'' ) AS hosp_pat_id_len 
FROM
	mst_coop_distribute mcd 
WHERE
	mcd.facility_cd = @facilityCd 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
	AND mcd.coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	AND mcd.coop_cd = ''rep_dial'' 
	AND mcd.coop_cd_index like ''%listxml'' 
	AND mcd.direction = ''S''
	AND is_disp =''1''
	AND is_del =''0''
UNION
select 
 2 AS order_no ,
(''0'')::TEXT AS  hosp_pat_id_len
ORDER BY
    order_no ASC LIMIT 1
		', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '富士通', '2022-04-04 16:37:06.785', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-63, 'WITH pdf_path_info AS (
SELECT
				0 AS order_no,
        COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS pdf_file_path
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
        AND info ->> ''key1'' = ''REPORT_SEND'' 
        AND info ->> ''key2'' = ''URL_PREFIX'' 
)
,data_info AS (
  SELECT
    TO_CHAR((CASE WHEN ord.rst_fn_dialysis_no IS NOT NULL AND ord.rst_fn_dialysis_no > 0 THEN ord.rst_fn_dialysis_no ELSE ord.ord_no END), ''FM0999999999999999999'') AS ord_no
    , ord.rst_edition
    , coop.hosp_pat_id
  FROM
    ord_main AS ord, sys_coop_journal AS coop
  WHERE
    ord.ord_no = @ordNo
  AND coop.ctl_no = @ctlNo
  AND coop.ord_no = ord.ord_no
)
, hosp_pat_id_length AS (
	SELECT
	COALESCE(NULLIF(((distribute_setting -> ''protocolInfo'' ->> ''hospPatIdLen'') :: INTEGER), NULL), 0) AS len
	FROM
	mst_coop_distribute
	WHERE
		facility_cd = @facilityCd 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
		AND coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
		AND is_del = ''0'' 
		AND coop_cd = ''rep_dial''
		AND coop_cd_index like ''%pdf''
		AND direction = ''S''
	ORDER BY len DESC
	LIMIT 1
)
SELECT
  pdf_path_info.pdf_file_path|| LPAD(LTRIM(data_info.hosp_pat_id) , len, ''0'') 
	|| ''/''
  || LTRIM(data_info.hosp_pat_id)
  || (CASE WHEN CHAR_LENGTH(ord_no::TEXT) > 12 THEN RIGHT(ord_no::TEXT,12) ELSE RPAD(ord_no::TEXT, 12, ''0'') END)
  || LPAD(rst_edition::TEXT, 4, ''0'') 
  || ''.pdf'' AS filename
FROM data_info,pdf_path_info,hosp_pat_id_length
WHERE pdf_path_info.order_no = 0', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）PDFファイルパスの取得', '2022-04-04 16:37:06.279', CURRENT_TIMESTAMP, NULL);
