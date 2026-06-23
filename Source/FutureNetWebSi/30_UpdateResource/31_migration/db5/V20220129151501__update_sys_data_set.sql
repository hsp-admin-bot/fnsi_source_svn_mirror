delete from "sys_data_set" where "sql_cd" in (1801,1802);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1801, 'UPDATE pat_main 
SET taboo_allergy_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)患者基本情報_禁忌・アレルギー情報_クリア', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1802, 'WITH memoInfo AS (
  SELECT 
    ''【分類】'' || ''@tabooAllergyInfo.content'' || ''\n''
    ''【開始日】'' || ''@tabooAllergyInfo.startDate'' || ''\n''
    ''【症状】'' || ''@tabooAllergyInfo.symptom'' || ''\n''
    ''【マスタ一致】該当なし（'' || ''@tabooAllergyInfo.tabooAllergyCd'' || ''）'' AS meno
) 
, taboo_allergy_existed AS ( 
  SELECT
    0 AS order_no
    , idx AS idx
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.taboo_allergy_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND ms ->> ''taboo_allergy_cd'' :: TEXT = ''@tabooAllergyInfo.tabooAllergyCd''
  UNION
  SELECT
    1 AS order_no
	  , -1 AS idx
  ORDER BY order_no ASC, idx ASC LIMIT 1
) 
UPDATE pat_main 
SET taboo_allergy_info =
CASE
    ''@tabooAllergyInfoFlg'' 
    WHEN '''' THEN
    ''@tabooAllergyInfoValue'' ELSE taboo_allergy_info || (''[{"memo":"'' || (SELECT meno FROM memoInfo) || ''", "ctl_no":"@nextCtlNo3", "content":"@tabooAllergyInfo.content", "disp_order":'' || COALESCE(NULLIF(''@tabooAllergyInfo.dispOrder'', ''''), ''null'') || '', "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'') :: jsonb 
  END 
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND (SELECT idx FROM taboo_allergy_existed) = ''-1''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通__禁忌・アレルギー情報_更新', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
