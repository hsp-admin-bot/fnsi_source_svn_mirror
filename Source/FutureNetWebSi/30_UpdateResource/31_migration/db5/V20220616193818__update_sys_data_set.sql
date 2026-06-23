DELETE FROM sys_data_set WHERE sql_cd IN (9606);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9606, 'UPDATE pat_main 
SET taboo_allergy_info =
CASE WHEN (''@tabooAllergyInfoFlg'' = '''') THEN
    ''@tabooAllergyInfoValue'' 
ELSE
	CASE WHEN ''@tabooAllergyInfo.categoryClass'' = ''0'' AND ''@tabooAllergyInfo.tabooAllergyClass'' = ''2'' AND ''@tabooAllergyInfo.tabooAllergyCd'' = ''''  AND COALESCE(''@tabooAllergyInfo.memo'', ''[]'') like ''%アレルギー%'' THEN
	    CASE WHEN json_array_contains_array_value(COALESCE(taboo_allergy_info, ''[]''), ''taboo_allergy_cd'',  ''@tabooAllergyInfo.tabooAllergyCd'') AND json_array_contains_array_value(COALESCE(taboo_allergy_info, ''[]''), ''taboo_allergy_class'',  ''@tabooAllergyInfo.tabooAllergyClass'') AND json_array_contains_array_value(COALESCE(taboo_allergy_info, ''[]''), ''content'',  ''@tabooAllergyInfo.content'') AND json_array_contains_array_value(COALESCE(taboo_allergy_info, ''[]''), ''category_class'',  ''@tabooAllergyInfo.categoryClass'') THEN
	      taboo_allergy_info
	    WHEN COALESCE(''@tabooAllergyInfo.memo'', ''[]'') like ''%【分類】金属アレルギー%'' THEN taboo_allergy_info || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@tabooAllergyInfo.dispOrder", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"【分類】金属アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'' :: jsonb
			WHEN COALESCE(''@tabooAllergyInfo.memo'', ''[]'') like ''%【分類】食物アレルギー%'' THEN taboo_allergy_info || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@tabooAllergyInfo.dispOrder", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"【分類】食物アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'' :: jsonb
			WHEN COALESCE(''@tabooAllergyInfo.memo'', ''[]'') like ''%【分類】造影剤アレルギー%'' THEN taboo_allergy_info || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@tabooAllergyInfo.dispOrder", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"【分類】造影剤アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'' :: jsonb
			WHEN COALESCE(''@tabooAllergyInfo.memo'', ''[]'') like ''%【分類】その他アレルギー%'' THEN taboo_allergy_info || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@tabooAllergyInfo.dispOrder", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"【分類】その他アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'' :: jsonb
	    	ELSE taboo_allergy_info || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@tabooAllergyInfo.dispOrder", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'' :: jsonb END
	ELSE taboo_allergy_info || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@tabooAllergyInfo.dispOrder", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'' :: jsonb 
	END 
END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(禁忌・アレルギー情報)', '2022-06-09 12:45:07.732', CURRENT_TIMESTAMP, NULL);
