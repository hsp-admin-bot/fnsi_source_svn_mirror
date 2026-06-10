DELETE FROM "ntss"."sys_data_set" WHERE sql_cd in (9618, 9627, 9619, 9616, 9617);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9618, 'UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', ''【分類】食物アレルギー'' || E''\n'' || (CASE WHEN ''@tabooAllergyInfo.memo'' != ''''
                                                     THEN ''【内容】''||''@tabooAllergyInfo.memo''
																										 ELSE '''' END) ::TEXT ,
                      ''ctl_no'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')::integer,
                      ''content'', ''@tabooAllergyInfo.content''::TEXT,
                      ''disp_order'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')::integer,
                      ''category_class'', ''@tabooAllergyInfo.categoryClass''::TEXT,
                      ''taboo_allergy_cd'', CASE ''@tabooAllergyInfo.tabooAllergyCd'' WHEN '''' THEN null ELSE ''@tabooAllergyInfo.tabooAllergyCd'' END,
                      ''taboo_allergy_class'', ''@tabooAllergyInfo.tabooAllergyClass''::TEXT,
											''new_flag'',1) WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(食物アレルギー情報)', '2022-07-12 02:55:43.381', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9619, 'UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', ''【分類】造影剤アレルギー'' || E''\n'' || (CASE WHEN ''@tabooAllergyInfo.memo'' != ''''
                                                     THEN ''【内容】''||''@tabooAllergyInfo.memo''
																										 ELSE '''' END) ::TEXT ,
                      ''ctl_no'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')::integer,
                      ''content'', ''@tabooAllergyInfo.content''::TEXT,
                      ''disp_order'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')::integer,
                      ''category_class'', ''@tabooAllergyInfo.categoryClass''::TEXT,
                      ''taboo_allergy_cd'', CASE ''@tabooAllergyInfo.tabooAllergyCd'' WHEN '''' THEN null ELSE ''@tabooAllergyInfo.tabooAllergyCd'' END,
                      ''taboo_allergy_class'', ''@tabooAllergyInfo.tabooAllergyClass''::TEXT,
											''new_flag'',1) WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(禁忌・アレルギー情報)', '2022-06-09 12:45:07.732', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9617, 'UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', ''【分類】その他アレルギー'' || E''\n'' || (CASE WHEN ''@tabooAllergyInfo.memo'' != ''''
                                                     THEN ''【内容】''||''@tabooAllergyInfo.memo''
																										 ELSE '''' END) ::TEXT ,
                      ''ctl_no'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')::integer,
                      ''content'', ''@tabooAllergyInfo.content''::TEXT,
                      ''disp_order'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')::integer,
                      ''category_class'', ''@tabooAllergyInfo.categoryClass''::TEXT,
                      ''taboo_allergy_cd'', CASE ''@tabooAllergyInfo.tabooAllergyCd'' WHEN '''' THEN null ELSE ''@tabooAllergyInfo.tabooAllergyCd'' END,
                      ''taboo_allergy_class'', ''@tabooAllergyInfo.tabooAllergyClass''::TEXT,
											''new_flag'',1) WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(その他アレルギー情報)', '2022-07-12 02:55:43.381', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9616, 'UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', ''【分類】金属アレルギー'' || E''\n'' || (CASE WHEN ''@tabooAllergyInfo.memo'' != ''''
                                                     THEN ''【内容】''||''@tabooAllergyInfo.memo''
																										 ELSE '''' END) ::TEXT ,
                      ''ctl_no'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')::integer,
                      ''content'', ''@tabooAllergyInfo.content''::TEXT,
                      ''disp_order'', COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')::integer,
                      ''category_class'', ''@tabooAllergyInfo.categoryClass''::TEXT,
                      ''taboo_allergy_cd'', CASE ''@tabooAllergyInfo.tabooAllergyCd'' WHEN '''' THEN null ELSE ''@tabooAllergyInfo.tabooAllergyCd'' END,
                      ''taboo_allergy_class'', ''@tabooAllergyInfo.tabooAllergyClass''::TEXT,
											''new_flag'',1) WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(金属アレルギー情報)', '2022-07-12 02:55:43.381', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9627, 'WITH check_taboo_allergy_cd as (select (case ''@tabooAllergyInfo.tabooAllergyCd''
                                            when '''' then false
                                            else true end) as ctac)
   , tabooAllergyCdInfo AS (SELECT (case
                                        when ctac then ''@tabooAllergyInfo.tabooAllergyCd''
                                        else null end)                                 AS cd
                                 , (case
                                        when ctac then ''1''
                                        else ''5'' end)                                AS type
                            from check_taboo_allergy_cd)
   , newTabooAllergyInfo AS (SELECT ''【分類】薬剤アレルギー'' || E''\n'' || (CASE WHEN ''@tabooAllergyInfo.memo'' != ''''
                                                     THEN ''【内容】''||''@tabooAllergyInfo.memo''
																										 ELSE '''' END) ::TEXT                    AS memo
                                  , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')            AS ctl_no
                                  , ''@tabooAllergyInfo.content''::TEXT                   AS content
                                  , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')            AS disp_order
                                  , type ::TEXT                                         AS category_class
                                  , cd                                                  AS taboo_allergy_cd
                                  , ''@tabooAllergyInfo.tabooAllergyClass''::TEXT         AS taboo_allergy_class
                             FROM tabooAllergyCdInfo)
UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = taboo_allergy_info || jsonb_build_object(''memo'', memo,
                      ''ctl_no'', ctl_no::integer,
                      ''content'', content,
                      ''disp_order'', disp_order::integer,
                      ''category_class'', category_class,
                      ''taboo_allergy_cd'', taboo_allergy_cd,
                      ''taboo_allergy_class'', taboo_allergy_class,
											''new_flag'',1) FROM newTabooAllergyInfo WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(薬剤アレルギー情報)', '2022-06-09 12:45:07.732', CURRENT_TIMESTAMP, NULL);
