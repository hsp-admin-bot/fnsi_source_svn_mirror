delete from "sys_data_set" where "sql_cd" in(-99992,-99986,-83,-82,-78,-64,-55);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99992, 'SELECT
  ''DIASCH-'' || 
  RIGHT(ordCoopNo.coop_ord_no,8)   || ''-'' ||
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') ||
  ''.dat'' AS filename
FROM
  ord_coop_no AS ordCoopNo ,sys_coop_journal AS journal 
WHERE
  ordCoopNo.ord_no = journal.ord_no and 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  ordCoopNo.coop_version = journal.coop_version and 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  journal.ctl_no =  @ctlNo;', 2, '[]', '0', '{"applications": [4]}', NULL, '日機装 透析予約[送信]ファイル名取得', '2022-05-02 13:29:17.807', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99986, 'WITH report_send_type_info AS ( 
  -- レポートファイル連携方式：0：HTML本文送信連携 1：URL連携
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS report_send_type 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''REPORT_SEND'' 
    AND info ->> ''key2'' = ''REPORT_SEND_TYPE'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS report_send_type 
  ORDER BY
    order_no ASC LIMIT 1
) 
, permission_change_info AS ( 
  -- パーミッション変更：0：しない、1：する
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS permission_change 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''REPORT_SEND'' 
    AND info ->> ''key2'' = ''PERMISSION_CHANGE'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS permission_change 
  ORDER BY
    order_no ASC LIMIT 1
) 
, sentence_type_info AS ( 
  -- 文書種別
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS sentence_type 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''REPORT_SEND'' 
    AND info ->> ''key2'' = ''SENTENCE_TYPE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS sentence_type 
  ORDER BY
    order_no ASC LIMIT 1
) 
, document_no_setting_info AS (
  -- 文書番号末尾設定:0：無し、1：01固定
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS document_no_setting 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''DOCUMENT_NO_SETTING'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS document_no_setting 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ord_no_info AS (
  SELECT
    TO_CHAR((CASE WHEN rst_fn_dialysis_no IS NOT NULL AND rst_fn_dialysis_no > 0 THEN rst_fn_dialysis_no ELSE ord_no END), ''FM09999999999999999999999999999999'') AS ord_no
  FROM
    ord_main AS ord
  WHERE
    ord_no = @ordNo
) 
, crud_info AS (
  -- 作成更新区分を取得
  SELECT crud FROM sys_coop_journal WHERE ctl_no = @ctlNo
)
, del_cnt_info AS (
-- 削除回数（ゼロ詰め3桁）
  SELECT CASE WHEN (SELECT crud FROM crud_info) = ''D'' THEN TO_CHAR(COUNT(1) - 1, ''FM099'') ELSE TO_CHAR(COUNT(1), ''FM099'') END AS del_cnt
    FROM ord_coop_no AS coopno
   WHERE coopno.facility_cd = @facilityCd AND coopno.pat_id = @patId AND coopno.ord_no= @ordNo AND coopno.coop_cd = ''rep_dial'' AND coopno.is_del = ''1'' 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
   AND coop_version = (SELECT coop_version FROM sys_coop_journal WHERE ctl_no = @ctlNo) 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
)

SELECT 
  SUBSTR(RPAD(COALESCE(NULLIF((SELECT sentence_type FROM sentence_type_info), ''''), ''''), 8, '' ''), 1, 4)
  || LPAD(RIGHT(@coopOrdNo, 8), 8, ''0'')
  || (SELECT del_cnt FROM del_cnt_info)
  || CASE WHEN COALESCE(NULLIF((SELECT document_no_setting FROM document_no_setting_info), ''''), ''0'') = ''0'' 
     THEN RIGHT(ord_no, 15)
     ELSE RIGHT(ord_no, 13) || ''01''
     END 
  AS ftp_path 
  , COALESCE(NULLIF((SELECT permission_change FROM permission_change_info), ''''), ''0'') AS permission_change
FROM ord_no_info 
WHERE (SELECT report_send_type FROM report_send_type_info) = ''0'' -- 0：HTML本文送信連携 
UNION 
SELECT 
  (''|NULL|'')::TEXT AS ftp_path -- URL連携の場合、空の文字列識別子を返します。
  , (''0'')::TEXT AS permission_change -- URL連携の場合、「0：しない」を返します。
WHERE (SELECT report_send_type FROM report_send_type_info) != ''0'' -- 1：URL連携 
', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通→HTML 本文送信→PDF送信の際→FTPのフォルダを取得する', '2022-04-11 14:41:48.497', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-83, '
WITH del_time AS (
  SELECT
		(CASE COUNT(*)
			WHEN 0 THEN
				''0''
			ELSE
				(COUNT(*)-1)::TEXT
			END)AS del
	FROM
		ord_coop_no ocn
	WHERE
		ocn.coop_cd = ''rst_dial'' 
		AND ocn.ord_no = @ordNo
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
		AND facility_cd = @facilityCd 
		AND coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
		AND ocn.is_del = ''1''
)

SELECT
  (CASE 
		WHEN rst_fn_dialysis_no > 0 THEN
		LPAD(del, 3, ''0'') || SUBSTR(LPAD(rst_fn_dialysis_no::TEXT, 20, ''0''), 4, 20)
		ELSE
		LPAD(del, 3, ''0'') || SUBSTR(LPAD(ord_no::TEXT, 20, ''0''), 4, 20) 
		END)  AS document_no
FROM
	ord_main, del_time
WHERE
	ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析実績削除：伝票情報.文書番号取得', '2022-11-25 00:24:25.924', CURRENT_TIMESTAMP, '[]');
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-82, '
WITH del_time AS (
  SELECT
	  COUNT(*)::TEXT AS del
	FROM
		ord_coop_no ocn
	WHERE
		ocn.coop_cd = ''rst_dial'' 
		AND ocn.ord_no = @ordNo
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
		AND facility_cd = @facilityCd 
		AND coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
		AND ocn.is_del = ''1''
)

SELECT
  (CASE 
		WHEN rst_fn_dialysis_no > 0 THEN
		LPAD(del, 3, ''0'') || SUBSTR(LPAD(rst_fn_dialysis_no::TEXT, 20, ''0''), 4, 20)
		ELSE
		LPAD(del, 3, ''0'') || SUBSTR(LPAD(ord_no::TEXT, 20, ''0''), 4, 20) 
		END)  AS document_no
FROM
	ord_main, del_time
WHERE
	ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：伝票情報.文書番号取得', '2022-10-17 06:57:59.087', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-78, 'WITH document_no_info AS(
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') = ''1'' 
      THEN ''01''
      ELSE ''00'' 
      END AS document_no 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''FJI_COM_INFO''
    AND info->>''key2'' = ''DOCUMENT_NO_SETTING''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''00'' AS document_no 
  ORDER BY order_no ASC LIMIT 1
)
, ord_coop_no_info AS (
  SELECT
    ctl_no,
		ord_no,
		facility_cd,
	  coop_ord_no
  FROM
	  ord_coop_no
	WHERE
	  pat_id = @patId
		AND
		ord_no = @ordNo
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
		AND facility_cd = @facilityCd 
		AND coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	ORDER BY
	  up_date DESC
	LIMIT 1
)
, ord_main_restore_info AS (
  SELECT
	  ord_no,
		facility_cd
	FROM
	  ord_main_restore
	WHERE
	  ord_no = @ordNo
		AND
		facility_cd = @facilityCd 
	ORDER BY
	  del_date DESC
	LIMIT 1
)
SELECT
  ocn.coop_ord_no || (SELECT document_no FROM document_no_info) AS ord_no
FROM
  ord_main_restore_info AS ord
	, ord_coop_no_info AS ocn
WHERE
  ord.ord_no = @ordNo
	AND ord.facility_cd = @facilityCd 
	AND ord.ord_no = ocn.ord_no
	AND ord.facility_cd = ocn.facility_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：文書番号(オーダ番号)取得', '2022-09-06 01:55:56.256', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-64, 'WITH document_no_info AS(
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') = ''1'' 
      THEN ''01''
      ELSE ''00'' 
      END AS document_no 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''FJI_COM_INFO''
    AND info->>''key2'' = ''DOCUMENT_NO_SETTING''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''00'' AS document_no 
  ORDER BY order_no ASC LIMIT 1
)
, ord_coop_no_info as (
  SELECT
    ctl_no,
		ord_no,
		facility_cd,
	  coop_ord_no
  FROM
	  ord_coop_no
	WHERE
	  pat_id = @patId
		AND
		ord_no = @ordNo
		AND 
		coop_cd = (SELECT coop_cd FROM sys_coop_journal WHERE ctl_no = @ctlNo)
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
		AND facility_cd = (SELECT facility_cd FROM sys_coop_journal WHERE ctl_no = @ctlNo)
		AND coop_version = (SELECT coop_version FROM sys_coop_journal WHERE ctl_no = @ctlNo)
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	ORDER BY
	  up_date DESC
	LIMIT 1
)
SELECT
	ocn.coop_ord_no || (SELECT document_no FROM document_no_info) AS ord_no
FROM
  ord_main AS ord
	, ord_coop_no_info AS ocn
WHERE
  ord.ord_no = @ordNo
	AND ord.facility_cd = @facilityCd
	AND ord.ord_no = ocn.ord_no
	AND ord.facility_cd = ocn.facility_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：文書番号(オーダ番号)取得', '2022-03-28 14:02:26.673', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-55, 'WITH sentence_type_info AS ( 
  -- 文書種別
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS sentence_type 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		AND COALESCE(info ->> ''key0'','''') = @key0
    AND info ->> ''key1'' = ''REPORT_SEND'' 
    AND info ->> ''key2'' = ''SENTENCE_TYPE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS sentence_type 
  ORDER BY
    order_no ASC LIMIT 1
) 
, document_no_setting_info AS (
  -- 文書番号末尾設定:0：無し、1：01固定
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS document_no_setting 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		AND COALESCE(info ->> ''key0'','''') = @key0
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''DOCUMENT_NO_SETTING'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS document_no_setting 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ord_no_info AS (
  SELECT
    TO_CHAR((CASE WHEN rst_fn_dialysis_no IS NOT NULL AND rst_fn_dialysis_no > 0 THEN rst_fn_dialysis_no ELSE ord_no END), ''FM09999999999999999999999999999999'') AS ord_no
  FROM
    ord_main AS ord
  WHERE
    ord_no = @ordNo
)
, crud_info AS (
  -- 作成更新区分を取得
  SELECT crud FROM sys_coop_journal WHERE ctl_no = @ctlNo
)
, del_cnt_info AS (
-- 削除回数（ゼロ詰め3桁）
  SELECT CASE WHEN (SELECT crud FROM crud_info) = ''D'' THEN TO_CHAR(COUNT(1) - 1, ''FM099'') ELSE TO_CHAR(COUNT(1), ''FM099'') END AS del_cnt
    FROM ord_coop_no AS coopno
   WHERE coopno.facility_cd = @facilityCd AND coopno.pat_id = @patId AND coopno.ord_no= @ordNo AND coopno.coop_cd = ''rep_dial'' AND coopno.is_del = ''1'' 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
   AND coop_version = (SELECT coop_version FROM sys_coop_journal WHERE ctl_no = @ctlNo)
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
)
SELECT
  SUBSTR(RPAD(COALESCE(NULLIF((SELECT sentence_type FROM sentence_type_info), ''''), ''''), 8, '' ''), 1, 4) AS sentence_type
  , (SELECT del_cnt FROM del_cnt_info) || CASE WHEN COALESCE(NULLIF((SELECT document_no_setting FROM document_no_setting_info), ''''), ''0'') = ''0'' 
    THEN RIGHT(ord_no, 15)
    ELSE RIGHT(ord_no, 13) || ''01''
    END AS ord_no
FROM ord_no_info', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析レポートの文書番号を取得', '2022-04-04 16:37:06.134', CURRENT_TIMESTAMP, NULL);
