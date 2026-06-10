delete from  "sys_data_set" where "sql_cd" = 1802;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1802, 'WITH tabooAllergyCdInfo AS (
  SELECT
    split_part(''@tabooAllergyInfo.tabooAllergyCd'', '','', 1) AS cd
    , split_part(''@tabooAllergyInfo.tabooAllergyCd'', '','', 2) AS type
    , split_part(''@tabooAllergyInfo.tabooAllergyCd'', '','', 3) AS hospital_cd
)
, newTabooAllergyInfo AS (
  SELECT 
    ''【分類】'' || (CASE type WHEN ''1'' THEN ''薬剤'' 
                             WHEN ''2'' THEN ''調製薬剤'' 
                             WHEN ''3'' THEN ''医療材料'' 
                             WHEN ''4'' THEN ''ダイアライザ'' 
                             WHEN ''5'' THEN ''フリーワード'' 
                             WHEN ''6'' THEN ''一般名処方'' 
                             ELSE ''不明'' END) || ''\n''
    ''【開始日】'' || ''@tabooAllergyInfo.startDate'' || ''\n''
    ''【症状】'' || ''@tabooAllergyInfo.symptom'' || ''\n''
    ''【マスタ一致】連携コード（'' || hospital_cd || ''）''::TEXT AS memo
    , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'') AS ctl_no 
    , ''@tabooAllergyInfo.content''::TEXT AS content 
    , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'') AS disp_order 
    , ''@tabooAllergyInfo.categoryClass''::TEXT AS category_class 
    , cd AS taboo_allergy_cd 
    , ''@tabooAllergyInfo.tabooAllergyClass''::TEXT AS taboo_allergy_class 
  FROM tabooAllergyCdInfo
) 
, tabooAllergyInfo AS ( 
  SELECT
    0 AS order_no
    , (idx - 1) AS idx
    , CASE WHEN position(new.memo in (REPLACE(ms->>''memo'', CHR(10), ''\n''))) > 0 THEN REPLACE(ms->>''memo'', CHR(10), ''\n'') ELSE (REPLACE(ms->>''memo'', CHR(10), ''\n'') || ''\n'' || new.memo) END AS memo
    , ms->>''ctl_no'' AS ctl_no 
    , ms->>''content'' AS content 
    , ms->>''disp_order'' AS disp_order 
    , ms->>''category_class'' AS category_class 
    , ms->>''taboo_allergy_cd'' AS taboo_allergy_cd 
    , ms->>''taboo_allergy_class'' AS taboo_allergy_class 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.taboo_allergy_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
    INNER JOIN newTabooAllergyInfo AS new ON new.taboo_allergy_cd = ms->>''taboo_allergy_cd''
--                                        AND new.category_class =  ms->>''category_class'' AND new.taboo_allergy_class =  ms->>''taboo_allergy_class''
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
  UNION
  SELECT
    1 AS order_no
    , NULL AS idx
    , memo 
    , ctl_no 
    , content 
    , disp_order 
    , category_class 
    , taboo_allergy_cd 
    , taboo_allergy_class 
  FROM newTabooAllergyInfo
  ORDER BY order_no ASC, idx ASC LIMIT 1
) 
UPDATE pat_main 
SET
  taboo_allergy_info = jsonb_set(COALESCE(taboo_allergy_info, ''[]'') ::JSONB
    , CAST((SELECT ''{'' || COALESCE(idx, 999) || ''}'' FROM tabooAllergyInfo) AS TEXT []) 
    , CAST((SELECT ''{"memo":"'' || memo || ''", ''
           || ''"ctl_no":'' || ctl_no || '', ''
           || ''"content":"'' || CONTENT || ''", ''
           || ''"disp_order":'' || disp_order || '', ''
           || ''"category_class":"'' || category_class || ''", ''
           || ''"taboo_allergy_cd":"'' || taboo_allergy_cd || ''", ''
           || ''"taboo_allergy_class":"'' || taboo_allergy_class|| ''"}''
        FROM tabooAllergyInfo) AS JSONB) ::JSONB) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
--  AND (SELECT idx FROM tabooAllergyInfo) IS NULL', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通__禁忌・アレルギー情報_更新', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
