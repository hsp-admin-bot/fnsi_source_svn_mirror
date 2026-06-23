DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN ('9616', '9617', '9618', '9619', '9622', '9623', '9624', '9625', '9626');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9626, 'WITH newRecAdd as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tt FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t
WHERE
  tt->>''memo'' like ''【分類】造影剤アレルギー%'' AND tt->>''flag'' = ''add''
),

newRecMod as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tt FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t
WHERE
  tt->>''memo'' like ''【分類】造影剤アレルギー%'' AND tt->>''flag'' = ''mod''
),

newRecCnt as (SELECT count(*) as newCnt FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as t7 FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t8
WHERE
  t7->>''memo'' like ''【分類】造影剤アレルギー%'' AND t7->>''flag'' IN (''add'', ''mod'')),
  
 orgRec as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tai FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t2
WHERE
  tai->>''memo'' like ''【分類】造影剤アレルギー%'' AND tai NOT IN (SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as t3 FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t4
WHERE
  t3->>''memo'' like ''【分類】造影剤アレルギー%'' AND t3->>''flag'' IN (''add'', ''mod''))
)

UPDATE pat_main
SET taboo_allergy_info = 
CASE WHEN taboo_allergy_info != ''[]'' THEN
    CASE WHEN newRecCnt.newCnt > 0 THEN
	    CASE WHEN EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】造影剤アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'') THEN
	        --造影剤アレルギーあり
	    	--金属以外、更新項目、追加項目
	    	COALESCE((
                SELECT jsonb_agg((taboo_allergy_info->>(idx - 1)::INT)::jsonb) AS tabooAllergyInfo
        	    FROM pat_main
        	    CROSS JOIN jsonb_array_elements(taboo_allergy_info)
        	    WITH ORDINALITY arr(j, idx)
        	    WHERE j->>''memo'' NOT like ''%【分類】造影剤アレルギー%''
        	    	AND pat_id = @patId 
        	    	AND facility_cd = ''@facilityCd''
        	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg((replace(tai::text, (tai->''memo'')::text, (tt->''memo'')::text))::jsonb) as taboo FROM orgRec, newRecMod WHERE ((orgRec.tai->>''content'')::text || '''') = ((newRecMod.tt->>''content'')::text || '''')
	    	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg(tt::jsonb - ''flag'') FROM newRecAdd
	    	)::jsonb, ''[]'')
        ELSE
	        --造影剤アレルギーなし
            taboo_allergy_info
        END
	ELSE
        taboo_allergy_info
	END
ELSE
    taboo_allergy_info
END
FROM newRecCnt
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(その他アレルギー情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9625, 'WITH newRecAdd as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tt FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t
WHERE
  tt->>''memo'' like ''【分類】食物アレルギー%'' AND tt->>''flag'' = ''add''
),

newRecMod as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tt FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t
WHERE
  tt->>''memo'' like ''【分類】食物アレルギー%'' AND tt->>''flag'' = ''mod''
),

newRecCnt as (SELECT count(*) as newCnt FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as t7 FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t8
WHERE
  t7->>''memo'' like ''【分類】食物アレルギー%'' AND t7->>''flag'' IN (''add'', ''mod'')),
  
 orgRec as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tai FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t2
WHERE
  tai->>''memo'' like ''【分類】食物アレルギー%'' AND tai NOT IN (SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as t3 FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t4
WHERE
  t3->>''memo'' like ''【分類】食物アレルギー%'' AND t3->>''flag'' IN (''add'', ''mod''))
)

UPDATE pat_main
SET taboo_allergy_info = 
CASE WHEN taboo_allergy_info != ''[]'' THEN
    CASE WHEN newRecCnt.newCnt > 0 THEN
	    CASE WHEN EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】食物アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'') THEN
	        --食物アレルギーあり
	    	--金属以外、更新項目、追加項目
	    	COALESCE((
                SELECT jsonb_agg((taboo_allergy_info->>(idx - 1)::INT)::jsonb) AS tabooAllergyInfo
        	    FROM pat_main
        	    CROSS JOIN jsonb_array_elements(taboo_allergy_info)
        	    WITH ORDINALITY arr(j, idx)
        	    WHERE j->>''memo'' NOT like ''%【分類】食物アレルギー%''
        	    	AND pat_id = @patId 
        	    	AND facility_cd = ''@facilityCd''
        	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg((replace(tai::text, (tai->''memo'')::text, (tt->''memo'')::text))::jsonb) as taboo FROM orgRec, newRecMod WHERE ((orgRec.tai->>''content'')::text || '''') = ((newRecMod.tt->>''content'')::text || '''')
	    	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg(tt::jsonb - ''flag'') FROM newRecAdd
	    	)::jsonb, ''[]'')
        ELSE
	        --金属アレルギーなし
            taboo_allergy_info
        END
	ELSE
        taboo_allergy_info
	END
ELSE
    taboo_allergy_info
END
FROM newRecCnt
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(金属アレルギー情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9624, 'WITH newRecAdd as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tt FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t
WHERE
  tt->>''memo'' like ''【分類】その他アレルギー%'' AND tt->>''flag'' = ''add''
),

newRecMod as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tt FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t
WHERE
  tt->>''memo'' like ''【分類】その他アレルギー%'' AND tt->>''flag'' = ''mod''
),

newRecCnt as (SELECT count(*) as newCnt FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as t7 FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t8
WHERE
  t7->>''memo'' like ''【分類】その他アレルギー%'' AND t7->>''flag'' IN (''add'', ''mod'')),
  
 orgRec as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tai FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t2
WHERE
  tai->>''memo'' like ''【分類】その他アレルギー%'' AND tai NOT IN (SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as t3 FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t4
WHERE
  t3->>''memo'' like ''【分類】その他アレルギー%'' AND t3->>''flag'' IN (''add'', ''mod''))
)

UPDATE pat_main
SET taboo_allergy_info = 
CASE WHEN taboo_allergy_info != ''[]'' THEN
    CASE WHEN newRecCnt.newCnt > 0 THEN
	    CASE WHEN EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】その他アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'') THEN
	        --その他アレルギーあり
	    	--金属以外、更新項目、追加項目
	    	COALESCE((
                SELECT jsonb_agg((taboo_allergy_info->>(idx - 1)::INT)::jsonb) AS tabooAllergyInfo
        	    FROM pat_main
        	    CROSS JOIN jsonb_array_elements(taboo_allergy_info)
        	    WITH ORDINALITY arr(j, idx)
        	    WHERE j->>''memo'' NOT like ''%【分類】その他アレルギー%''
        	    	AND pat_id = @patId 
        	    	AND facility_cd = ''@facilityCd''
        	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg((replace(tai::text, (tai->''memo'')::text, (tt->''memo'')::text))::jsonb) as taboo FROM orgRec, newRecMod WHERE ((orgRec.tai->>''content'')::text || '''') = ((newRecMod.tt->>''content'')::text || '''')
	    	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg(tt::jsonb - ''flag'') FROM newRecAdd
	    	)::jsonb, ''[]'')
        ELSE
	        --金属アレルギーなし
            taboo_allergy_info
        END
	ELSE
        taboo_allergy_info
	END
ELSE
    taboo_allergy_info
END
FROM newRecCnt
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(その他アレルギー情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9623, 'UPDATE
    pat_main t1 
SET taboo_allergy_info = 
CASE WHEN taboo_allergy_info != ''[]'' THEN
(SELECT jsonb_agg(((taboo_allergy_info->>(idx - 1)::INT)::jsonb || concat(concat(''{"disp_order": "'', idx), ''"}'')::jsonb))
    FROM pat_main
    CROSS JOIN jsonb_array_elements(taboo_allergy_info)
    WITH ORDINALITY arr(j, idx)
    WHERE pat_id = @patId AND facility_cd = ''@facilityCd'')
ELSE
    taboo_allergy_info
END
WHERE 
    pat_id = @patId AND facility_cd = ''@facilityCd''
;', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(アレルギー情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9622, 'WITH newRecAdd as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tt FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t
WHERE
  tt->>''memo'' like ''【分類】金属アレルギー%'' AND tt->>''flag'' = ''add''
),

newRecMod as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tt FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t
WHERE
  tt->>''memo'' like ''【分類】金属アレルギー%'' AND tt->>''flag'' = ''mod''
),

newRecCnt as (SELECT count(*) as newCnt FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as t7 FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t8
WHERE
  t7->>''memo'' like ''【分類】金属アレルギー%'' AND t7->>''flag'' IN (''add'', ''mod'')),
  
 orgRec as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tai FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t2
WHERE
  tai->>''memo'' like ''【分類】金属アレルギー%'' AND tai NOT IN (SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as t3 FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t4
WHERE
  t3->>''memo'' like ''【分類】金属アレルギー%'' AND t3->>''flag'' IN (''add'', ''mod''))
)

UPDATE pat_main
SET taboo_allergy_info = 
CASE WHEN taboo_allergy_info != ''[]'' THEN
    CASE WHEN newRecCnt.newCnt > 0 THEN
	    CASE WHEN EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】金属アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'') THEN
	        --金属アレルギーあり
	    	--金属以外、更新項目、追加項目
	    	COALESCE((
                SELECT jsonb_agg((taboo_allergy_info->>(idx - 1)::INT)::jsonb) AS tabooAllergyInfo
        	    FROM pat_main
        	    CROSS JOIN jsonb_array_elements(taboo_allergy_info)
        	    WITH ORDINALITY arr(j, idx)
        	    WHERE j->>''memo'' NOT like ''%【分類】金属アレルギー%''
        	    	AND pat_id = @patId 
        	    	AND facility_cd = ''@facilityCd''
        	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg((replace(tai::text, (tai->''memo'')::text, (tt->''memo'')::text))::jsonb) as taboo FROM orgRec, newRecMod WHERE ((orgRec.tai->>''content'')::text || '''') = ((newRecMod.tt->>''content'')::text || '''')
	    	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg(tt::jsonb - ''flag'') FROM newRecAdd
	    	)::jsonb, ''[]'')
        ELSE
	        --金属アレルギーなし
            taboo_allergy_info
        END
	ELSE
        taboo_allergy_info
	END
ELSE
    taboo_allergy_info
END
FROM newRecCnt
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(金属アレルギー情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9619, 'UPDATE pat_main
SET taboo_allergy_info = 
    CASE WHEN EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】造影剤アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'' AND value like ''%"content": "@tabooAllergyInfo.content"%'') THEN
	    --ある場合は変更
		CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
		    taboo_allergy_info || cast(concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】造影剤アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') as text) :: jsonb
		ELSE
		    taboo_allergy_info || cast(concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】造影剤アレルギー", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') as text) :: jsonb
		END
	ELSE
	    --なし場合は追加
		CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
		    taboo_allergy_info || ''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】造影剤アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'' :: jsonb
		ELSE
		    taboo_allergy_info || ''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】造影剤アレルギー", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'' :: jsonb
		END
	END
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(禁忌・アレルギー情報)', '2022-06-09 12:45:07.732', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9618, 'UPDATE pat_main
SET taboo_allergy_info = 
    CASE WHEN EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】食物アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'' AND value like ''%"content": "@tabooAllergyInfo.content"%'') THEN
	    --ある場合は変更
		CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
		    taboo_allergy_info || cast(concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】食物アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') as text) :: jsonb
		ELSE
		    taboo_allergy_info || cast(concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】食物アレルギー", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') as text) :: jsonb
		END
	ELSE
	    --なし場合は追加
		CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
		    taboo_allergy_info || ''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】食物アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'' :: jsonb
		ELSE
		    taboo_allergy_info || ''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】食物アレルギー", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'' :: jsonb
		END
	END
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(食物アレルギー情報)', '2022-07-12 02:55:43.381', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9617, 'UPDATE pat_main
SET taboo_allergy_info = 
    CASE WHEN EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】その他アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'' AND value like ''%"content": "@tabooAllergyInfo.content"%'') THEN
	    --ある場合は変更
		CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
		    taboo_allergy_info || cast(concat(concat(''[{"ctl_no":"'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order":"@nextCtlNo3", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo": "【分類】その他アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') as text) :: jsonb
		ELSE
		    taboo_allergy_info || cast(concat(concat(''[{"ctl_no":"'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order":"@nextCtlNo3", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo": "【分類】その他アレルギー", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') as text) :: jsonb
		END
	ELSE
	    --なし場合は追加
		CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
		    taboo_allergy_info || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@nextCtlNo3", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo": "【分類】その他アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'' :: jsonb
		ELSE
		    taboo_allergy_info || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@nextCtlNo3", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo": "【分類】その他アレルギー", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'' :: jsonb
		END
	END
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(その他アレルギー情報)', '2022-07-12 02:55:43.381', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9616, 'UPDATE pat_main
SET taboo_allergy_info = 
    CASE WHEN EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】金属アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'' AND value like ''%"content": "@tabooAllergyInfo.content"%'') THEN
	    --ある場合は変更
		CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
		    taboo_allergy_info || cast(concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】金属アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') as text) :: jsonb
		ELSE
		    taboo_allergy_info || cast(concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】金属アレルギー", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') as text) :: jsonb
		END
	ELSE
	    --なし場合は追加
		CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
		    taboo_allergy_info || ''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】金属アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'' :: jsonb
		ELSE
		    taboo_allergy_info || ''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd", "content": "@tabooAllergyInfo.content", "memo": "【分類】金属アレルギー", "category_class": "@tabooAllergyInfo.categoryClass", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'' :: jsonb
		END
	END
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(金属アレルギー情報)', '2022-07-12 02:55:43.381', CURRENT_TIMESTAMP, NULL);
