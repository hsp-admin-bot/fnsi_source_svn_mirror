DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN ('9627', '9628');

INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9628, 'WITH newRecMod as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tt FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t
WHERE
  tt->>''memo'' like ''【分類】薬剤アレルギー%'' AND tt->>''flag'' = ''mod''
),

newRecAdd as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as ta FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t
WHERE
  ta->>''memo'' like ''【分類】薬剤アレルギー%'' AND ta->>''flag'' = ''add''
),

newRecCnt as (SELECT count(*) as newCnt FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as t7 FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t8
WHERE
  t7->>''memo'' like ''【分類】薬剤アレルギー%'' AND t7->>''flag'' IN (''add'', ''mod'')),
  
 orgRec as (
SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as tai FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t2
WHERE
  tai->>''memo'' like ''【分類】薬剤アレルギー%'' AND tai NOT IN (SELECT * FROM (
  SELECT jsonb_array_elements(taboo_allergy_info) as t3 FROM pat_main WHERE pat_id = @patId AND facility_cd = ''@facilityCd''
) t4
WHERE
  t3->>''memo'' like ''【分類】薬剤アレルギー%'' AND t3->>''flag'' IN (''add'', ''mod''))
),
mstRec as (
    SELECT medicine_cd as seq, medicine_name as name FROM mst_medicine WHERE facility_cd = ''@facilityCd'' AND in_hospital_cd_1 = ''@tabooAllergyInfo.tabooAllergyCd''
)

UPDATE pat_main
SET taboo_allergy_info = 
CASE WHEN taboo_allergy_info != ''[]'' THEN
    CASE WHEN newRecCnt.newCnt > 0 THEN
	    CASE WHEN EXISTS(SELECT * FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) WHERE pat_id = @patId AND value like ''%"memo": "【分類】薬剤アレルギー%'' AND (value like ''%"taboo_allergy_cd": ""%'' or value like concat(concat(''%"taboo_allergy_cd": "'', concat(concat(''"'', (select seq from mstRec)), ''"'')), ''"%''))) THEN
	        --薬剤アレルギーあり
	    	--薬剤以外、更新項目、追加項目
	    	COALESCE((
                SELECT jsonb_agg((taboo_allergy_info->>(idx - 1)::INT)::jsonb) AS tabooAllergyInfo
        	    FROM pat_main
        	    CROSS JOIN jsonb_array_elements(taboo_allergy_info)
        	    WITH ORDINALITY arr(j, idx)
        	    WHERE j->>''memo'' NOT like ''%【分類】薬剤アレルギー%''
        	    	AND pat_id = @patId 
        	    	AND facility_cd = ''@facilityCd''
        	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg((replace(tai::text, (tai->''memo'')::text, (tt->''memo'')::text))::jsonb) as taboo FROM orgRec, newRecMod WHERE ((orgRec.tai->>''content'')::text || '''') = ((newRecMod.tt->>''content'')::text || '''')
	    	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg((replace(ta::text, (ta->''memo'')::text, (tt->''memo'')::text))::jsonb - ''flag'') as taboo FROM newRecAdd, newRecMod WHERE ((newRecAdd.ta->>''content'')::text || '''') = ((newRecMod.tt->>''content'')::text || '''')
	    	)::jsonb, ''[]'') || COALESCE((
	    	    SELECT jsonb_agg(ta::jsonb - ''flag'') FROM newRecAdd WHERE NOT EXISTS (
	  SELECT 1 FROM (SELECT * FROM newRecMod) tMod WHERE tt->>''content'' = ta->>''content''
	)
	    	)::jsonb, ''[]'')
        ELSE
	        --薬剤アレルギーなし
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
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(その他アレルギー情報)', '2022-07-27 06:23:44.367', CURRENT_TIMESTAMP, NULL);
  
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9627, 'WITH mstRec as (
    SELECT medicine_cd as seq, medicine_name as name FROM mst_medicine WHERE facility_cd = ''@facilityCd'' AND in_hospital_cd_1 = ''@tabooAllergyInfo.tabooAllergyCd''
),
recInMst as (
    SELECT count(*) as count FROM mstRec
)

UPDATE pat_main
SET taboo_allergy_info = 
  CASE WHEN ''@tabooAllergyInfo.tabooAllergyCd'' = '''' THEN
		CASE WHEN ''@tabooAllergyInfo.content'' != '''' THEN
			CASE WHEN EXISTS(SELECT jTbl.* FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) jTbl, mstRec WHERE pat_id = @patId AND value like ''%"memo": "【分類】薬剤アレルギー%'' AND (value like concat(concat(''%"taboo_allergy_cd": '', (select seq from mstRec)), ''%'') OR (value like ''%"taboo_allergy_cd": ""%'' AND value like ''%"content": "@tabooAllergyInfo.content"%''))) THEN
	        --ある場合は変更
					CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
						taboo_allergy_info || concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "", "content": "@tabooAllergyInfo.content", "memo": "【分類】薬剤アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "5", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') :: jsonb
					ELSE
		        taboo_allergy_info || concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "", "content": "@tabooAllergyInfo.content", "memo": "【分類】薬剤アレルギー", "category_class": "5", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') :: jsonb
					END
		  ELSE
			   CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
				taboo_allergy_info || concat(concat(''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "", "content": "@tabooAllergyInfo.content", "memo": "【分類】薬剤アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "5", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'')) :: jsonb
				 ELSE taboo_allergy_info || concat(concat(''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "", "content": "@tabooAllergyInfo.content", "memo": "【分類】薬剤アレルギー", "category_class": "5", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'')) :: jsonb
		     END
			 END
		 ELSE
			 taboo_allergy_info
		 END
  ELSE  
	  CASE WHEN (select count from recInMst) > 0 THEN 
			CASE WHEN EXISTS(SELECT jTbl.* FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) jTbl, mstRec WHERE pat_id = @patId AND value like ''%"memo": "【分類】薬剤アレルギー%'' AND value like concat(concat(''%"taboo_allergy_cd": '', (select seq from mstRec)), ''%'')) THEN
	        --ある場合は変更
	    	CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
		        taboo_allergy_info || concat(concat(concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": '', (select seq from mstRec)), '', "content": "'', (select name from mstRec)), ''", "memo": "【分類】薬剤アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "1", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') :: jsonb
		    ELSE
		        taboo_allergy_info || concat(concat(concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": '', (select seq from mstRec)), '', "content": "'', (select name from mstRec)), ''", "memo": "【分類】薬剤アレルギー", "category_class": "1", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') :: jsonb
		    END
	    ELSE
	        --なし場合は追加
			CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
				taboo_allergy_info || concat(concat(concat(concat(''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": '', (select seq from mstRec)), '', "content": "'', (select name from mstRec)), ''", "memo": "【分類】薬剤アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "1", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'')) :: jsonb
			ELSE
				taboo_allergy_info || concat(concat(concat(concat(''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": '', (select seq from mstRec)), '', "content": "'', (select name from mstRec)), ''", "memo": "【分類】薬剤アレルギー", "category_class": "1", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'')) :: jsonb
			END
	    END
		ELSE 
			CASE WHEN EXISTS(SELECT jTbl.* FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) jtbl WHERE pat_id = @patId AND value like ''%"memo": "【分類】薬剤アレルギー%'' AND value like ''%"taboo_allergy_cd": "@tabooAllergyInfo.tabooAllergyCd"%'') THEN
	        --ある場合は変更
	    	CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
		        taboo_allergy_info || concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "", "content": "@tabooAllergyInfo.content", "memo": "【分類】薬剤アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "5", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') :: jsonb
		    ELSE
		        taboo_allergy_info || concat(concat(''[{"ctl_no": "'', cast((cast(@nextCtlNo3 as int) - 1) as text)), ''", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "", "content": "@tabooAllergyInfo.content", "memo": "【分類】薬剤アレルギー", "category_class": "5", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"mod"}]'') :: jsonb
		    END
	    ELSE
	        --なし場合は追加
				CASE WHEN ''@tabooAllergyInfo.memo'' != '''' THEN
				taboo_allergy_info || concat(concat(''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "", "content": "@tabooAllergyInfo.content", "memo": "【分類】薬剤アレルギー\n【内容】@tabooAllergyInfo.memo", "category_class": "5", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'')) :: jsonb
				ELSE
					taboo_allergy_info || concat(concat(''[{"ctl_no": "@nextCtlNo3", "disp_order": "@nextCtlNo3", "taboo_allergy_cd": "", "content": "@tabooAllergyInfo.content", "memo": "【分類】薬剤アレルギー", "category_class": "5", "taboo_allergy_class": "@tabooAllergyInfo.tabooAllergyClass", "flag":"add"}]'')) :: jsonb
				END
	    END
		END
	END
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(薬剤アレルギー情報)', '2022-06-09 12:45:07.732', CURRENT_TIMESTAMP, NULL);
