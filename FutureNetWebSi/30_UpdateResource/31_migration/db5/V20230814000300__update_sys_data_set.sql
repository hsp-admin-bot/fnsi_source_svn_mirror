DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 9627;

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9627, 'WITH check_taboo_allergy_cd as (select (case ''@tabooAllergyInfo.tabooAllergyCd''
                                            when '''' then false
                                            else true end) as ctac)
   , tabooAllergyCdInfo AS (SELECT (case
                                        when ctac then ''@tabooAllergyInfo.tabooAllergyCd''
                                        else '''' end)                                 AS cd
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
