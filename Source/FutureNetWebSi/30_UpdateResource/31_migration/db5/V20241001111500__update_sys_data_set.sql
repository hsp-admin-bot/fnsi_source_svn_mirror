DELETE FROM sys_data_set sds WHERE sql_cd  = 1802;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(1802, 'WITH 
	coop_ini_data AS (
	  SELECT
	    COALESCE(NULLIF(ini_info ->> ''value'', ''''), ini_info ->> ''default_v'') AS value,
	    ini_info ->> ''key2'' as key2
	  FROM
	    mst_coop_ini AS ini 
	    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
	  WHERE
	    ini.is_del = ''0''
	    AND ini.is_disp = ''1''
	    AND ini.facility_cd = ''@facilityCd''
	    AND COALESCE(ini_info->>''key0'','''') = ''@key0''
	    AND TRIM(ini_info ->> ''key1'') = ''TABOO_CD'' 
	)
	,taboo AS (
	  SELECT
	     taboo_allergy_cd AS cd
	  FROM
	     mst_taboo_allergy
	  WHERE
	    facility_cd = ''@facilityCd''
	    AND is_del = ''0'' 
	    AND is_disp = ''1''
	    AND CASE (SELECT value FROM coop_ini_data WHERE key2 = ''TABOO'')
			WHEN ''1'' THEN in_hospital_cd_1
			WHEN ''2'' THEN in_hospital_cd_2
			ELSE null
			END = ''@tabooAllergyInfo.tabooAllergyCd''
	    limit 1
	)
	,taboo_allergy_medicine AS (
	  SELECT
	     medicine_cd AS cd
	  FROM
	     mst_medicine
	  WHERE
	    facility_cd = ''@facilityCd''
	    AND is_del = ''0'' 
	    AND is_disp = ''1''
	    AND CASE (SELECT value FROM coop_ini_data WHERE key2 = ''MEDICINE'')
			WHEN ''1'' THEN in_hospital_cd_1
			WHEN ''2'' THEN in_hospital_cd_2
			WHEN ''3'' THEN in_hospital_cd_3
			WHEN ''4'' THEN in_hospital_cd_4
			ELSE null
			END = ''@tabooAllergyInfo.tabooAllergyCd''
	    limit 1
	)
	,taboo_allergy_equipment AS (
	  SELECT
	     equipment_cd AS cd
	  FROM
	     mst_equipment
	  WHERE
	    facility_cd = ''@facilityCd''
	    AND is_del = ''0'' 
	    AND is_disp = ''1''
	    AND CASE (SELECT value FROM coop_ini_data WHERE key2 = ''EQUIPMENT'')
			WHEN ''1'' THEN in_hospital_cd_1
			WHEN ''2'' THEN in_hospital_cd_2
			WHEN ''3'' THEN in_hospital_cd_3
			WHEN ''4'' THEN in_hospital_cd_4
			ELSE null
			END = ''@tabooAllergyInfo.tabooAllergyCd''
	    limit 1
	)
	,taboo_allergy_dialyzer AS (
	  SELECT
	     dialyzer_cd AS cd
	  FROM
	     mst_dialyzer
	  WHERE
	    facility_cd = ''@facilityCd''
	    AND is_del = ''0'' 
	    AND is_disp = ''1''
	    AND CASE (SELECT value FROM coop_ini_data WHERE key2 = ''DIALYZER'')
			WHEN ''1'' THEN in_hospital_cd_1
			WHEN ''2'' THEN in_hospital_cd_2
			WHEN ''3'' THEN in_hospital_cd_3
			WHEN ''4'' THEN in_hospital_cd_4
			ELSE null
			END = ''@tabooAllergyInfo.tabooAllergyCd''
	    limit 1
	)
	,tabooAllergyCdInfo as (
	select
		(case
		    when (select nullif(cd, null) from taboo) is NOT NULL then (select nullif(cd, null) from taboo)
			when (select nullif(cd, null) from taboo_allergy_medicine) is NOT NULL then (select nullif(cd, null) from taboo_allergy_medicine)
			when (select nullif(cd, null) from taboo_allergy_equipment) is NOT NULL then (select nullif(cd, null) from taboo_allergy_equipment)
			when (select nullif(cd, null) from taboo_allergy_dialyzer) is NOT NULL then (select nullif(cd, null) from taboo_allergy_dialyzer)
			else null
		end) as cd
		,
		(case
			when (select nullif(cd, null) from taboo) is NOT NULL then ''0''
			when (select nullif(cd, null) from taboo_allergy_medicine) is NOT NULL then ''1''
			when (select nullif(cd, null) from taboo_allergy_equipment) is NOT NULL then ''3''
			when (select nullif(cd, null) from taboo_allergy_dialyzer) is NOT NULL then ''4''
			else ''5''
		end) as type)
   , newTabooAllergyInfo AS (SELECT ''【分類】'' || (CASE type
                                                     WHEN ''0'' THEN ''禁忌・アレルギー''
                                                     WHEN ''1'' THEN ''薬剤''
                                                     WHEN ''2'' THEN ''調製薬剤''
                                                     WHEN ''3'' THEN ''医療材料''
                                                     WHEN ''4'' THEN ''ダイアライザ''
                                                     WHEN ''5'' THEN ''フリーワード''
                                                     WHEN ''6'' THEN ''一般名処方''
                                                     ELSE ''不明'' END) || E''\n''
                                        ''【開始日】'' || ''@tabooAllergyInfo.startDate'' || E''\n''
                                        ''【症状】'' || ''@tabooAllergyInfo.symptom'' || E''\n''
                                         || (CASE type
                                                     WHEN ''5'' THEN ''【マスタ一致】該当なし（''
                                                     ELSE ''【マスタ一致】連携コード（'' END) || ''@tabooAllergyInfo.tabooAllergyCd'' || ''）''::TEXT AS memo
                                  , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')            AS ctl_no
                                  , ''@tabooAllergyInfo.content''::TEXT                   AS content
                                  , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')            AS disp_order
                                  , type::TEXT             AS category_class
                                  , cd::TEXT                                            AS taboo_allergy_cd
                                  , ''@tabooAllergyInfo.tabooAllergyClass''::TEXT         AS taboo_allergy_class
                             FROM tabooAllergyCdInfo)
   , tabooAllergyInfo AS (SELECT 0                                                                        AS order_no
                               , (idx - 1)                                                                AS idx
                               , REPLACE(REPLACE(ms ->> ''memo'', CHR(10), ''\n''), ''\n'', E''\n'')        AS memo
                               , ms ->> ''ctl_no''                                                          AS ctl_no
                               , ms ->> ''content''                                                         AS content
                               , ms ->> ''disp_order''                                                      AS disp_order
                               , ms ->> ''category_class''                                                  AS category_class
                               , ms ->> ''taboo_allergy_cd''                                                AS taboo_allergy_cd
                               , ms ->> ''taboo_allergy_class''                                             AS taboo_allergy_class
                          FROM pat_main AS A
                                   CROSS JOIN LATERAL jsonb_array_elements(A.taboo_allergy_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
                                   INNER JOIN newTabooAllergyInfo AS new
                                              ON (COALESCE(ms ->> ''taboo_allergy_cd'', '''') <> '''' and new.taboo_allergy_cd = ms ->> ''taboo_allergy_cd'' and new.category_class = ms ->> ''category_class'') or
                                                 (COALESCE(ms ->> ''taboo_allergy_cd'', '''') = '''' and new.content = ms ->> ''content'')
                          WHERE A.is_del = ''0''
                            AND A.facility_cd = ''@facilityCd''
                            AND A.pat_id = @patId
                          UNION
                          SELECT 1    AS order_no
                               , NULL AS idx
                               , memo
                               , ctl_no
                               , content
                               , disp_order
                               , category_class
                               , taboo_allergy_cd
                               , taboo_allergy_class
                          FROM newTabooAllergyInfo
                          ORDER BY order_no ASC, idx ASC
                          LIMIT 1)
   , existsCnt AS (select COUNT(exists_id) AS exists_cnt from
                       (
                       select 
                          pat_id AS exists_id
                          FROM pat_main,tabooAllergyInfo
                          CROSS JOIN LATERAL json_array_elements(taboo_allergy_info ::json) AS taboo_allergy_info_json
                          WHERE is_del = ''0''
                            AND pat_id = @patId
                            AND facility_cd = ''@facilityCd''
                            AND taboo_allergy_info_json  ->> ''memo'' = tabooAllergyInfo.memo
                            AND taboo_allergy_info_json  ->> ''content'' = tabooAllergyInfo.content
                            AND taboo_allergy_info_json  ->> ''category_class'' = tabooAllergyInfo.category_class
                            AND COALESCE(taboo_allergy_info_json  ->> ''taboo_allergy_cd'','''') = COALESCE(tabooAllergyInfo.taboo_allergy_cd,'''')
                            AND taboo_allergy_info_json  ->> ''taboo_allergy_class'' = tabooAllergyInfo.taboo_allergy_class
                          LIMIT 1) as existsData
                      )
   , tempTabooAllergyInfo AS (SELECT 
                                  REPLACE(REPLACE(ms ->> ''memo'', CHR(10), ''\n''), ''\n'', E''\n'')                      AS memo
                                , CASE WHEN ms ->> ''ctl_no'' < tabooAllergyInfo.ctl_no THEN ms ->> ''ctl_no''
                                  WHEN ms ->> ''ctl_no'' = tabooAllergyInfo.ctl_no THEN ''0''
                                  ELSE ((ms ->> ''ctl_no'')::integer - 1)::text END                                        AS ctl_no
                                , ms ->> ''content''                                                                       AS content
                                , CASE WHEN ms ->> ''disp_order'' < tabooAllergyInfo.disp_order THEN ms ->> ''disp_order''
                                  WHEN ms ->> ''disp_order'' = tabooAllergyInfo.disp_order THEN ''0''
                                  ELSE ((ms ->> ''disp_order'')::integer - 1)::text END                                    AS disp_order
                                , ms ->> ''category_class''                                                                AS category_class
                                , ms ->> ''taboo_allergy_cd''                                                              AS taboo_allergy_cd
                                , ms ->> ''taboo_allergy_class''                                                           AS taboo_allergy_class
                              FROM pat_main AS A, tabooAllergyInfo
                                CROSS JOIN LATERAL jsonb_array_elements(A.taboo_allergy_info ::jsonb) WITH ORDINALITY AS info(ms)
                              WHERE A.is_del = ''0''
                                AND A.facility_cd = ''@facilityCd''
                                AND A.pat_id = @patId
                              UNION
                              SELECT
                                  memo
                                , ctl_no
                                , content
                                , disp_order
                                , category_class
                                , taboo_allergy_cd
                                , taboo_allergy_class
                              FROM newTabooAllergyInfo
                              WHERE ''@tabooAllergyInfo.stopFlag'' = ''0'' 
                              ORDER BY ctl_no
   )
   , jsonTabooAllergyInfo AS (
       select to_jsonb(tempTabooAllergyInfo) FROM tempTabooAllergyInfo WHERE ctl_no <> ''0''
   )


UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
    taboo_allergy_info = (SELECT COALESCE(array_to_json(array_agg(to_jsonb)), ''[]''::json) FROM jsonTabooAllergyInfo)
FROM tabooAllergyInfo,existsCnt
WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND ((existsCnt.exists_cnt = 0 AND ''@tabooAllergyInfo.stopFlag'' = ''0'') OR (existsCnt.exists_cnt = 1 AND ''@tabooAllergyInfo.stopFlag'' = ''1''));', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)富士通__禁忌・アレルギー情報_更新', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);