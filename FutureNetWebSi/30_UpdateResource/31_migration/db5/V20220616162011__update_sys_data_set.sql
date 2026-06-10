DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (1049,1050,1051,1052,1053,1054,1055);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1049, 'SELECT
    pat_id,
    facility_cd,
    is_same,
    is_implant,
    is_infect,
    is_diabetes,
    is_blood_suger_exam,
    in_out_current_state,
    in_out_plan_state,
    in_out_plan_date,
    pat_memo_info,
    addition_info,
    charge_staff_info,
    pat_group_info,
    taboo_allergy_info,
    infect_info,
    implant_info,
    tare_info,
    off_water_info,
    device_set_info,
    acceptance_status_info,
    is_del,
    up_date,
    reg_date,
    is_wheel_chair,
    medical_care_info,
    sch_ext_end_date,
    sch_ext_status,
    card_idm,
    old_up_date,
    host_notification_info,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl1
        CROSS JOIN LATERAL json_array_elements ( tbl1.pat_memo_info :: json ) RESULT 
    WHERE
        tbl1.pat_id = @patId 
    ) AS next_ctl_no_1,
    (
 SELECT
             (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 

    FROM
        pat_main tbl2
        CROSS JOIN LATERAL json_array_elements ( tbl2.charge_staff_info :: json ) RESULT 
				
    WHERE
        tbl2.pat_id = @patId
    ) AS next_ctl_no_2,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl3
        CROSS JOIN LATERAL json_array_elements ( tbl3.taboo_allergy_info :: json ) RESULT 
    WHERE
        tbl3.pat_id = @patId 
    ) AS next_ctl_no_3,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl4
        CROSS JOIN LATERAL json_array_elements ( tbl4.infect_info :: json ) RESULT 
    WHERE
        tbl4.pat_id = @patId 
    ) AS next_ctl_no_4,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl5
        CROSS JOIN LATERAL json_array_elements ( tbl5.implant_info :: json ) RESULT 
    WHERE
        tbl5.pat_id = @patId 
    ) AS next_ctl_no_5 
FROM
    pat_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者個人情報の取得', '2022-06-16 02:19:05.74',CURRENT_TIMESTAMP , NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1050, 'UPDATE pat_main pm1
 SET
  pat_memo_info = 
	CASE
    ''@patMemoInfo.title'' 
    WHEN '''' THEN
    ''@patMemoInfoValue''
ELSE	jsonb_set(pat_memo_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main pm2, jsonb_array_elements(pat_memo_info) WITH

ORDINALITY WHERE pm1.pat_id = pm2.pat_id AND value->>''ctl_no'' = ''1'')::text, ''title''::text], ''"@patMemoInfo.title"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者メモの修正', '2022-06-11 07:38:42.336',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1051, 'SELECT
    pat_id,
    facility_cd,
    is_same,
    is_implant,
    is_infect,
    is_diabetes,
    is_blood_suger_exam,
    in_out_current_state,
    in_out_plan_state,
    in_out_plan_date,
    pat_memo_info,
    addition_info,
    charge_staff_info,
    pat_group_info,
    taboo_allergy_info,
    infect_info,
    implant_info,
    tare_info,
    off_water_info,
    device_set_info,
    acceptance_status_info,
    is_del,
    up_date,
    reg_date,
    is_wheel_chair,
    medical_care_info,
    sch_ext_end_date,
    sch_ext_status,
    card_idm,
    old_up_date,
    host_notification_info,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl1
        CROSS JOIN LATERAL json_array_elements ( tbl1.pat_memo_info :: json ) RESULT 
    WHERE
        tbl1.pat_id = @patId 
    ) AS next_ctl_no_1,
    (
 SELECT
             (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 

    FROM
        pat_main tbl2
        CROSS JOIN LATERAL json_array_elements ( tbl2.charge_staff_info :: json ) RESULT 
				
    WHERE
        tbl2.pat_id = @patId
    ) AS next_ctl_no_2,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl3
        CROSS JOIN LATERAL json_array_elements ( tbl3.taboo_allergy_info :: json ) RESULT 
    WHERE
        tbl3.pat_id = @patId 
    ) AS next_ctl_no_3,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl4
        CROSS JOIN LATERAL json_array_elements ( tbl4.infect_info :: json ) RESULT 
    WHERE
        tbl4.pat_id = @patId 
    ) AS next_ctl_no_4,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl5
        CROSS JOIN LATERAL json_array_elements ( tbl5.implant_info :: json ) RESULT 
    WHERE
        tbl5.pat_id = @patId 
    ) AS next_ctl_no_5 
FROM
    pat_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者個人情報の患者メモ2の取得',CURRENT_TIMESTAMP ,CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1052, 'UPDATE pat_main pm1
 SET
  pat_memo_info = 
	CASE
    ''@patMemoInfo.content'' 
    WHEN '''' THEN
    ''@patMemoInfoValue''
ELSE	jsonb_set(pat_memo_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main pm2, jsonb_array_elements(pat_memo_info) WITH

ORDINALITY WHERE pm1.pat_id = pm2.pat_id AND value->>''ctl_no'' = ''1'')::text, ''content''::text], ''"@patMemoInfo.content"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者メモ1の内容の修正',CURRENT_TIMESTAMP ,CURRENT_TIMESTAMP , NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1053, 'UPDATE pat_main pm1
 SET
  pat_memo_info = 
	CASE
    ''@patMemoInfo.content''
    WHEN '''' THEN
    ''@patMemoInfoValue''
ELSE	jsonb_set(pat_memo_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main pm2, jsonb_array_elements(pat_memo_info) WITH

ORDINALITY WHERE pm1.pat_id = pm2.pat_id AND value->>''ctl_no'' = ''@no'')::text, ''content''::text], ''"@patMemoInfo.content"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
	AND @no < 12
	AND @no > 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者メモ2の内容の修正',CURRENT_TIMESTAMP ,CURRENT_TIMESTAMP, '[{"sql_cd": 1055, "field_name": "no", "replace_var": "@no"}]');
	INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1054, 'UPDATE pat_main pm1
 SET
  pat_memo_info = 
	CASE
    ''@patMemoInfo.title'' 
    WHEN '''' THEN
    ''@patMemoInfoValue''
ELSE	jsonb_set(pat_memo_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main pm2, jsonb_array_elements(pat_memo_info) WITH

ORDINALITY WHERE pm1.pat_id = pm2.pat_id AND value->>''ctl_no'' = ''@no'')::text, ''title''::text], ''"@patMemoInfo.title"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
	AND @no < 12
	AND @no > 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者メモ2のタイトルの修正',CURRENT_TIMESTAMP , CURRENT_TIMESTAMP, '[{"sql_cd": 1055, "field_name": "no", "replace_var": "@no"}]');
	INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1055, 'select cast( (case @patMemoInfo.ctl_no
			
			WHEN '''' THEN
		''0'' ELSE @patMemoInfo.ctl_no
 END) as integer )+1 as no


	 ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者メモ順位の取得',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP , NULL);





