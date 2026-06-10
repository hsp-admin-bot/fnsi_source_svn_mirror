DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN ('9616', '9617');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9617, 'UPDATE pat_main
SET taboo_allergy_info = 
CASE WHEN ''@tabooAllergyInfo.content'' != '''' THEN
    CASE WHEN NOT EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】その他アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'' AND value like ''%"content": "@tabooAllergyInfo.content"%'') THEN
        -- add
    	CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
    	    ((
	  SELECT jsonb_agg((taboo_allergy_info->>(idx - 1)::INT)::jsonb) AS tabooAllergyInfo
		FROM pat_main
		CROSS JOIN jsonb_array_elements(taboo_allergy_info)
		WITH ORDINALITY arr(j, idx)
		WHERE (j->>''memo'' NOT like ''%【分類】その他アレルギー%''
		  OR j->>''taboo_allergy_cd'' != ''''
			OR j->>''content'' != ''"@tabooAllergyInfo.content"'')
			AND pat_id = @patId 
			AND facility_cd = ''@facilityCd''
		) || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@nextCtlNo3", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"【分類】その他アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'') :: jsonb
		ELSE
    	    ((
	  SELECT jsonb_agg((taboo_allergy_info->>(idx - 1)::INT)::jsonb) AS tabooAllergyInfo
		FROM pat_main
		CROSS JOIN jsonb_array_elements(taboo_allergy_info)
		WITH ORDINALITY arr(j, idx)
		WHERE (j->>''memo'' NOT like ''%【分類】その他アレルギー%''
		  OR j->>''taboo_allergy_cd'' != ''''
			OR j->>''content'' != ''"@tabooAllergyInfo.content"'')
			AND pat_id = @patId 
			AND facility_cd = ''@facilityCd''
		) || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@nextCtlNo3", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"【分類】その他アレルギー", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'') :: jsonb
    	END
    ELSE
        CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
    		    -- mod
    				jsonb_set(taboo_allergy_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main t2, jsonb_array_elements(taboo_allergy_info) WITH ORDINALITY WHERE pat_id = @patId AND value->>''memo'' like ''%【分類】その他アレルギー%'' AND value->>''taboo_allergy_cd'' = '''' AND value->>''content'' = ''@tabooAllergyInfo.content'')::text, ''memo''::text], ''"【分類】その他アレルギー\n【内容】@tabooAllergyInfo.memo"'')
    		ELSE
    		    -- mod
    				jsonb_set(taboo_allergy_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main t2, jsonb_array_elements(taboo_allergy_info) WITH ORDINALITY WHERE pat_id = @patId AND value->>''memo'' like ''%【分類】その他アレルギー%'' AND value->>''taboo_allergy_cd'' = '''' AND value->>''content'' = ''@tabooAllergyInfo.content'')::text, ''memo''::text], ''"【分類】その他アレルギー"'')
    		END
    END
ELSE
    taboo_allergy_info
END
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(禁忌・アレルギー情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9616, 'UPDATE pat_main
SET taboo_allergy_info = 
CASE WHEN taboo_allergy_info != ''[]'' THEN
    CASE WHEN ''@tabooAllergyInfo.content'' != '''' THEN
        CASE WHEN NOT EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】金属アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'' AND value like ''%"content": "@tabooAllergyInfo.content"%'') THEN
            -- add
        	CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
        	    ((
    	            SELECT jsonb_agg((taboo_allergy_info->>(idx - 1)::INT)::jsonb) AS tabooAllergyInfo
    		        FROM pat_main
    		        CROSS JOIN jsonb_array_elements(taboo_allergy_info)
    		        WITH ORDINALITY arr(j, idx)
    		        WHERE (j->>''memo'' NOT like ''%【分類】金属アレルギー%''
    		          OR j->>''taboo_allergy_cd'' != '''')
    		        	AND pat_id = @patId 
    		        	AND facility_cd = ''@facilityCd''
    		    ) || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@nextCtlNo3", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"【分類】金属アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'') :: jsonb
    		ELSE
        	    ((
    	            SELECT jsonb_agg((taboo_allergy_info->>(idx - 1)::INT)::jsonb) AS tabooAllergyInfo
    		        FROM pat_main
    		        CROSS JOIN jsonb_array_elements(taboo_allergy_info)
    		        WITH ORDINALITY arr(j, idx)
    		        WHERE (j->>''memo'' NOT like ''%【分類】金属アレルギー%''
    		          OR j->>''taboo_allergy_cd'' != '''')
    		        	AND pat_id = @patId 
    		        	AND facility_cd = ''@facilityCd''
    		    ) || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@nextCtlNo3", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"【分類】金属アレルギー", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'') :: jsonb
        	END
        ELSE
            CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
        	    -- mod
        			jsonb_set(taboo_allergy_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main t2, jsonb_array_elements(taboo_allergy_info) WITH ORDINALITY WHERE pat_id = @patId AND value->>''memo'' like ''%【分類】金属アレルギー%'' AND value->>''taboo_allergy_cd'' = '''' AND value->>''content'' = ''@tabooAllergyInfo.content'')::text, ''memo''::text], ''"【分類】金属アレルギー\n【内容】@tabooAllergyInfo.memo"'')
        	ELSE
        	    -- mod
        			jsonb_set(taboo_allergy_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main t2, jsonb_array_elements(taboo_allergy_info) WITH ORDINALITY WHERE pat_id = @patId AND value->>''memo'' like ''%【分類】金属アレルギー%'' AND value->>''taboo_allergy_cd'' = '''' AND value->>''content'' = ''@tabooAllergyInfo.content'')::text, ''memo''::text], ''"【分類】金属アレルギー"'')
        	END
        END
    ELSE
        taboo_allergy_info
    END
ELSE
    CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
    	    ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@nextCtlNo3", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"【分類】金属アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'' :: jsonb
		ELSE
    	    ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@nextCtlNo3", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"【分類】金属アレルギー", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'' :: jsonb
    	END
END
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(金属アレルギー情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
