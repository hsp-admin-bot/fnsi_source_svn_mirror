DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (9997,9996,9628,9627,9626,9625,9624,9623,9622,9621,9619,9618,9617,9616,9615,9614,9613,9612,9609,9607,7406,7405,7302,7206,7118,7116,7113,7109,7108,7105,7103,7102,7101,3104,3103,3100,2107,2106,1890,1999,1887,1885,1881,1802,1502,1210,1209,1104,1054,1053,1052,1050);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9997, 'with diseaseCdBoolean as (select (case ''@medicalHstInfo.diseaseCd''
                                      when '''' then true
                                      else false end) as status),
     diseaseDateBoolean as (select (case ''@medicalHstInfo.diseaseDate''
                                      when '''' then true
                                      else false end) as status)
update pat_unique
set medical_hst_info = (case when diseaseCdBoolean.status and diseaseDateBoolean.status then replace(cast(medical_hst_info as text),
                               ''"is_dialysis_underlying_disease": "1"'',
                               ''"is_dialysis_underlying_disease": "0"'')::jsonb else medical_hst_info end),
	up_date = CURRENT_TIMESTAMP
from diseaseCdBoolean, diseaseDateBoolean
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and is_del = ''0'';', 2, '[{}]', '0', '{"applications": [4]}', NULL, '', '2022-03-10 09:51:01.219', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9996, 'with diseaseCdBoolean as (select (case ''@medicalHstInfo.diseaseCd''
                                      when '''' then true
                                      else false end) as status),
     diseaseDateBoolean as (select (case ''@medicalHstInfo.diseaseDate''
                                      when '''' then true
                                      else false end) as status)
UPDATE pat_personal_main
SET primary_disease_cd = (case when diseaseCdBoolean.status and diseaseDateBoolean.status then null else primary_disease_cd end),
	up_date = CURRENT_TIMESTAMP
from diseaseCdBoolean, diseaseDateBoolean
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd'';', 3, '[{}]', '0', '{"applications": [4]}', NULL, '', '2022-03-10 09:51:01.219', CURRENT_TIMESTAMP, NULL);
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
END,
	up_date = CURRENT_TIMESTAMP
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
	END,
	up_date = CURRENT_TIMESTAMP
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(薬剤アレルギー情報)', '2022-06-09 12:45:07.732', CURRENT_TIMESTAMP, NULL);
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
END,
	up_date = CURRENT_TIMESTAMP
FROM newRecCnt
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(その他アレルギー情報)', '2022-08-05 11:33:04.204', CURRENT_TIMESTAMP, NULL);
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
END,
	up_date = CURRENT_TIMESTAMP
FROM newRecCnt
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(金属アレルギー情報)', '2022-08-05 11:33:04.319', CURRENT_TIMESTAMP, NULL);
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
END,
	up_date = CURRENT_TIMESTAMP
FROM newRecCnt
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(その他アレルギー情報)', '2022-08-05 11:33:04.436', CURRENT_TIMESTAMP, NULL);
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
END,
	up_date = CURRENT_TIMESTAMP
WHERE 
    pat_id = @patId AND facility_cd = ''@facilityCd''
;', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(アレルギー情報)', '2022-08-05 11:33:04.549', CURRENT_TIMESTAMP, NULL);
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
END,
	up_date = CURRENT_TIMESTAMP
FROM newRecCnt
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(金属アレルギー情報)', '2022-08-05 11:33:04.664', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9621, 'with nameSplit as (select split_part(''@otherContactInfo.lastName'' ,'' '', 1) as lastName,
                          split_part(''@otherContactInfo.lastName'' ,'' '', 2) as firstName),
     oldInfo as (select (other_contact_info ->> (idx - 1)::int)::json AS oldInfo
                 FROM pat_personal_main CROSS JOIN jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) WITH ORDINALITY arr(j, idx), nameSplit
                 WHERE (((j ->> ''first_name'')::text = nameSplit.firstName
               and (j ->> ''last_name'')::text = nameSplit.lastName)
    or (j ->> ''last_name'')::text = ''@otherContactInfo.lastName'')
                   and is_del = ''0''
                   AND hosp_pat_id = ''@hospPatId''
                   AND facility_cd = ''@facilityCd'')
UPDATE pat_personal_main
SET 
	up_date = CURRENT_TIMESTAMP,
other_contact_info = REPLACE(other_contact_info::text, oldInfo.oldInfo::text, ''{
                 "ctl_no": "@otherContactInfo.ctlNo",
                 "disp_order": "@otherContactInfo.dispOrder",
                 "is_key_person": "@otherContactInfo.isKeyPerson",
                 "pat_id": "@otherContactInfo.patId",
                 "last_name": "''||nameSplit.lastName||''",
                 "first_name": "''||nameSplit.firstName||''",
                 "last_name_kana": "@otherContactInfo.lastNmKana",
                 "first_name_kana": "@otherContactInfo.firstNmKana",
                 "relation_cd": ''||@relationCd||'',
                 "relation_name": "@otherContactInfo.relationName",
                 "zip_cd": "@otherContactInfo.zipCd",
                 "address": "@otherContactInfo.address",
                 "e_mail": "@otherContactInfo.eMail",
                 "work_name": "@otherContactInfo.workName",
                 "work_tel": "@otherContactInfo.workTel",
                 "tel1": "@otherContactInfo.tel1",
                 "tel2": "@otherContactInfo.tel2",
                 "fax": "@otherContactInfo.fax",
                 "memo1": "@otherContactInfo.memo1",
                 "memo2": "@otherContactInfo.memo2"
               }''::text)::jsonb
from nameSplit,oldInfo
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2022-06-27 12:39:15.173', CURRENT_TIMESTAMP, '[{"sql_cd": 9620, "field_name": "relation_cd", "replace_var": "@relationCd"}]');
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
	END,
	up_date = CURRENT_TIMESTAMP
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
	END,
	up_date = CURRENT_TIMESTAMP
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
	END,
	up_date = CURRENT_TIMESTAMP
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
	END,
	up_date = CURRENT_TIMESTAMP
WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(金属アレルギー情報)', '2022-07-12 02:55:43.381', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9615, 'with currentDate as (select to_char(current_date, ''yyyymmdd'') as nowDate),
     infectValue as (select (case
                                 when ''@infectInfo.infect'' = ''0''
                                     or ''@infectInfo.infect'' = ''1''
                                     or ''@infectInfo.infect'' = ''2''
                                     then ''@infectInfo.infect''
                                 else ''0'' end) as infectValue),
     examDate as (select to_char(to_date(''@infectInfo.examDate_Date'', ''yyyy-mm-dd''), ''yyyymmdd'') as examDate),
     changeOrNot as (select (case
                                 when (infectValue.infectValue <> coalesce(t0.infect, '''') or examDate.examDate <> coalesce(t0.exam_date, ''''))
                                     then true
                                 else false end) as res
                     from (select value ->> ''infect'' as infect, value ->> ''exam_date'' as exam_date
                           FROM pat_main,
                               jsonb_array_elements(infect_info) WITH ORDINALITY
                           WHERE is_del = ''0''
                             AND pat_id = @patId
                             AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'') t0,
                          infectValue,
                          examDate)
update pat_main
set 
	up_date = CURRENT_TIMESTAMP,
	infect_info = (case when ''@infectInfo.infectionCd'' != '''' and changeOrNot.res then jsonb_set(
        infect_info,
        array [
            (select ORDINALITY::INT - 1
             FROM pat_main d2,
                 jsonb_array_elements(infect_info) WITH ORDINALITY
             WHERE is_del = ''0''
               AND pat_id = @patId
               AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'')::text,
            ''exam_date''
            ],
        cast(''"''|| examDate.examDate ||''"'' as text)::jsonb
    ) else infect_info end)
from currentDate,
     infectValue,
     changeOrNot,
     examDate
WHERE is_del = ''0''
  AND pat_id = @patId
  and facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9614, 'with infectValue as (select (case
                                 when ''@infectInfo.infect'' = ''0''
                                     or ''@infectInfo.infect'' = ''1''
                                     or ''@infectInfo.infect'' = ''2''
                                     then ''@infectInfo.infect''
                                 else ''0'' end) as infectValue),
     examDate as (select to_char(to_date(''@infectInfo.examDate_Date'', ''yyyy-mm-dd''), ''yyyymmdd'') as examDate),
     changeOrNot as (select (case
                                 when (infectValue.infectValue <> coalesce(t0.infect, '''') or examDate.examDate <> coalesce(t0.exam_date, ''''))
                                     then true
                                 else false end) as res
                     from (select value ->> ''infect'' as infect, value ->> ''exam_date'' as exam_date
                           FROM pat_main,
                               jsonb_array_elements(infect_info) WITH ORDINALITY
                           WHERE is_del = ''0''
                             AND pat_id = @patId
                             AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'') t0,
                          infectValue,
                          examDate)
update pat_main
set 
	up_date = CURRENT_TIMESTAMP,
infect_info = (case
                       when ''@infectInfo.infectionCd'' != '''' and changeOrNot.res then jsonb_set(
                               infect_info,
                               array [
                                   (select ORDINALITY::INT - 1
                                    FROM pat_main d2,
                                        jsonb_array_elements(infect_info) WITH ORDINALITY
                                    WHERE is_del = ''0''
                                      AND pat_id = @patId
                                      AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'')::text,
                                   ''infect''
                                   ],
                               cast(''"'' || infectValue.infectValue || ''"'' as text)::jsonb
                           )
                       else infect_info end)
from infectValue,
     changeOrNot,
     examDate
WHERE is_del = ''0''
  AND pat_id = @patId
  and facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9613, 'with currentDate as (select to_char(current_date, ''yyyymmdd'') as nowDate),
     infectValue as (select (case
                                 when ''@infectInfo.infect'' = ''0''
                                     or ''@infectInfo.infect'' = ''1''
                                     or ''@infectInfo.infect'' = ''2''
                                     then ''@infectInfo.infect''
                                 else ''0'' end) as infectValue),
     examDate as (select to_char(to_date(''@infectInfo.examDate_Date'', ''yyyy-mm-dd''), ''yyyymmdd'') as examDate),
     changeOrNot as (select (case
                                 when (infectValue.infectValue <> coalesce(t0.infect, '''') or examDate.examDate <> coalesce(t0.exam_date, ''''))
                                     then true
                                 else false end) as res
                     from (select value ->> ''infect'' as infect, value ->> ''exam_date'' as exam_date
                           FROM pat_main,
                               jsonb_array_elements(infect_info) WITH ORDINALITY
                           WHERE is_del = ''0''
                             AND pat_id = @patId
                             AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'') t0,
                          infectValue,
                          examDate)
update pat_main
set 
	up_date = CURRENT_TIMESTAMP,
infect_info = (case
                       when ''@infectInfo.infectionCd'' != '''' and changeOrNot.res then jsonb_set(
                               infect_info,
                               array [
                                   (select ORDINALITY::INT - 1
                                    FROM pat_main d2,
                                        jsonb_array_elements(infect_info) WITH ORDINALITY
                                    WHERE is_del = ''0''
                                      AND pat_id = @patId
                                      AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'')::text,
                                   ''up_date''
                                   ],
                               cast(''"'' || currentDate.nowDate || ''"'' as text)::jsonb
                           )
                       else infect_info end)
from currentDate,
     infectValue,
     changeOrNot,
     examDate
WHERE is_del = ''0''
  AND pat_id = @patId
  and facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9612, 'update pat_personal_main 
set severity_cd = case when @severityCd is null then null else @severityCd::integer end,
	up_date = CURRENT_TIMESTAMP
where
  pat_id = @patId', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)profile連携（XML）で受信した詳細情報（重症度）', '2022-06-22 07:10:58.039', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9609, 'UPDATE pat_unique
SET medical_hst_info = (select jsonb_agg(lists)
                        from (select lists
                              from (select distinct on (t1.disease_cd) lists, disease_date as dDate
                                    from (select *
                                          from (select list ->> ''disease_cd''                     as disease_cd,
                                                       list ->> ''disease_date''                   as disease_date,
                                                       list ->> ''is_dialysis_underlying_disease'' as is_dialysis_underlying_disease,
                                                       list                                      as lists
                                                from pat_unique
                                                         cross join jsonb_array_elements(medical_hst_info) list
                                                where pat_id = @patId
                                                  and facility_cd = ''@facilityCd''
                                                  and is_del = ''0''
                                                order by disease_date desc) as t0
                                          order by t0.is_dialysis_underlying_disease desc) as t1) as t2
                              order by t2.dDate desc) as t3),
	up_date = CURRENT_TIMESTAMP
WHERE pat_id = @patId
  and facility_cd = ''@facilityCd''
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報更新', '2022-06-15 11:50:35.61', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9607, 'UPDATE pat_personal_main
SET primary_disease_cd = (CASE WHEN ''@diseaseCd'' != 0 THEN ''@diseaseCd'' ELSE primary_disease_cd END),
	up_date = CURRENT_TIMESTAMP
WHERE
    is_del = ''0'' 
    AND hosp_pat_id = ''@hospPatId'' 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2022-06-15 13:24:30.481', CURRENT_TIMESTAMP, '[{"sql_cd": 9608, "field_name": "disease_cd", "replace_var": "@diseaseCd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7406, 'UPDATE pat_exam_main pea1
 SET
  exam_result_info = 
	CASE
    ''@examResultInfo.itemCd'' 
    WHEN '''' THEN
    ''@examResultInfoValue''
ELSE	jsonb_set(exam_result_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_exam_main pea2, jsonb_array_elements(exam_result_info) WITH

ORDINALITY WHERE pea1.pat_id = pea2.pat_id AND value->>''item_cd'' = ''@examResultInfo.itemCd'' AND pea2.reg_order_class = ''@regOrderClass'' AND pea2.reg_exam_date = to_timestamp(''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss''))::text, ''result''::text], ''"@examResultInfo.result"'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @item_cd != ''0''
	AND reg_order_class = ''@regOrderClass''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 7407, "field_name": "item_cd", "replace_var": "@item_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7405, 'with examData as (select exam_class as examClass from mst_exam_item where exam_item_cd = ''@examResultInfo.itemCd'')
UPDATE pat_exam_main 
SET 
	up_date = CURRENT_TIMESTAMP,
exam_result_info = 
    CASE ''@examResultInfoFlg'' 
    WHEN '''' THEN
      ''@examResultInfoValue''
    ELSE
      CASE WHEN ''@examResultInfo.comCd1'' <> '''' AND ''@examResultInfo.comCd2'' <> '''' THEN
        exam_result_info || (''[{"com_cd":"@examResultInfo.comCd1, @examResultInfo.comCd2", "disp_order":"@nextDispOrder", "exam_class":"''||examData.examClass||''", "freememo":"@examResultInfo.freememo", "hl":"@examResultInfo.hl", "item_cd":"@examResultInfo.itemCd", "item_name":"@examResultInfo.itemName", "jlac10_cd":"@examResultInfo.jlac10Cd", "lower":"@examResultInfo.lower", "result":"@examResultInfo.result", "result_date":"@examResultInfo.resultDate", "type":"@examResultInfo.type", "unit":"@examResultInfo.unit", "upper":"@examResultInfo.upper"}]'') :: jsonb 
      ELSE
        exam_result_info || (''[{"com_cd":"@examResultInfo.comCd1@examResultInfo.comCd2", "disp_order":"@nextDispOrder", "exam_class":"''||examData.examClass||''", "freememo":"@examResultInfo.freememo", "hl":"@examResultInfo.hl", "item_cd":"@examResultInfo.itemCd", "item_name":"@examResultInfo.itemName", "jlac10_cd":"@examResultInfo.jlac10Cd", "lower":"@examResultInfo.lower", "result":"@examResultInfo.result", "result_date":"@examResultInfo.resultDate", "type":"@examResultInfo.type", "unit":"@examResultInfo.unit", "upper":"@examResultInfo.upper"}]'') :: jsonb 
      END
   END 
   from examData
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND reg_exam_date = to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
  AND reg_order_class = ''@regOrderClass'' 
  AND exam_main_cd = @examMainCd
	AND @item_cd = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(検査結果情報更新)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 7407, "field_name": "item_cd", "replace_var": "@item_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7302, 'with diseaseInfo as (select case ''@medicalHstInfo.diseaseCd'' when '''' then ''999999'' else ''@medicalHstInfo.diseaseCd'' end as diseaseCd),
     outComeInfo as (select case (select case when ''@isDie'' = ''1'' then ''10'' else ''@medicalHstInfo.outCome'' end)
                                when '''' then '' '' end as outCome),
     currentTime as (select case (select case when ''@isDie'' = ''1'' then to_char(CURRENT_TIMESTAMP,''YYYYMMDD'') else ''@medicalHstInfo.outComeDate'' end) when '''' then '' '' else ''@medicalHstInfo.outComeDate'' end as nowDate),
     medicalHstInfo as (select (case when medical_hst_info is null then ''[]''::jsonb else medical_hst_info end) as medical_hst_info
                        from pat_unique
                        where pat_id = @patId
                          and facility_cd = ''@facilityCd''
                          and is_del = ''0'')
update pat_unique
set 
	up_date = CURRENT_TIMESTAMP,
medical_hst_info = (case ''@medicalHstInfoFlg''
                           when '''' then medicalHstInfo.medical_hst_info
                           else (CASE
                                     WHEN ''@upBaseDiseaseFlg'' = ''0'' and ''@isDie'' = ''''  and ''@medicalHstInfo.diseaseDate''<> ''''
                                     and ''@medicalHstInfo.diseaseCd'' <> ''''
                                        THEN replace(cast(medicalHstInfo.medical_hst_info as text),
                                                                                 ''"is_dialysis_underlying_disease": "1"'',
                                                                                 ''"is_dialysis_underlying_disease": "0"'')::jsonb
                                     ELSE medicalHstInfo.medical_hst_info END)
                                     || case when (''@medicalHstInfo.diseaseCd'' <> '''' and ''@isDie'' = '''' and ''@medicalHstInfo.diseaseDate'' <> '''')
                                                    or (''@isDie'' = ''1'' and ''@medicalHstInfo.diseaseDate'' <> '''')
                                        then cast(''[{
                               "memo": "@medicalHstInfo.memo",
                               "ctl_no": "@nextCtlNo2",
                               "die_date": "@medicalHstInfo.dieDate",
                               "out_come": "''|| outComeInfo.outCome ||''",
                               "course_cd": "@medicalHstInfo.courseCd",
                               "is_notice": "@medicalHstInfo.isNotice",
                               "disease_cd": ''|| diseaseInfo.diseaseCd ||'',
                               "disp_order": "@medicalHstInfo.dispOrder",
                               "disease_day": "'' || substr(replace(''@medicalHstInfo.diseaseDate'', ''/'', ''''), 7, 2) || ''",
                               "facility_cd": "@medicalHstInfo.facilityCd",
                               "disease_date": "@medicalHstInfo.diseaseDate",
                               "disease_year": "'' || substr(replace(''@medicalHstInfo.diseaseDate'', ''/'', ''''), 1, 4) || ''",
                               "is_diagnosed": "@medicalHstInfo.isDiagnosed",
                               "diagnosis_day": "@medicalHstInfo.diagnosisDay",
                               "disease_month": "'' || substr(replace(''@medicalHstInfo.diseaseDate'', ''/'', ''''), 5, 2) || ''",
                               "out_come_date": "''||currentTime.nowDate||''",
                               "course_is_free": "@medicalHstInfo.courseIsFree",
                               "diagnosis_date": "@medicalHstInfo.diagnosisDate",
                               "diagnosis_year": "@medicalHstInfo.diagnosisYear",
                               "diagnosis_month": "@medicalHstInfo.diagnosisMonth",
                               "is_main_disease": "@medicalHstInfo.isMainDisease",
                               "diagnostician_cd": "@medicalHstInfo.diagnosticianCd",
                               "diagnosis_facility_cd": "@medicalHstInfo.diagnosisFacilityCd",
                               "diagnostician_is_free": "@medicalHstInfo.diagnosticianIsFree",
                               "is_confirmation_biopsy": "@medicalHstInfo.isConfirmationBiopsy",
                               "diagnosis_facility_is_free": "@medicalHstInfo.diagnosisFacilityIsFree",
                               "is_dialysis_underlying_disease": "''|| CASE WHEN ''@upBaseDiseaseFlg'' = ''0'' and ''@isDie'' = '''' THEN ''1'' ELSE ''0''END ||''"}]'' as text)::jsonb else ''[]''::jsonb end
    end)
        from diseaseInfo,outComeInfo,currentTime,medicalHstInfo
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(既往歴情報情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7206, 'WITH infectionInfo AS ( 
  SELECT
    (idx - 1) AS idx
    , ms ->> ''infection_cd'' AS infection_cd 
    ,CASE ''@infectInfo.infect'' 
        WHEN '''' THEN 0 
        WHEN ''不明'' THEN 0 
        ELSE TO_NUMBER(''@infectInfo.infect'', ''FM9999999999999999'') 
       END   AS infect
    , SUBSTR(COALESCE(TO_CHAR(TO_TIMESTAMP(NULLIF(''@infectInfo.examDate_Date'', ''''), ''yyyy-MM-dd hh24:mi:ss''), ''yyyyMMdd''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')), 1, 8) AS exam_date
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.infect_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND ms ->> ''infection_cd'' :: TEXT = ''@infectInfo.infectionCd''
) 
UPDATE pat_main 
SET infect_info = jsonb_set (
  COALESCE ( infect_info, ''[]'' ) :: JSONB,
  CAST ( ( SELECT ''{'' ||  idx || ''}'' FROM infectionInfo ) AS TEXT [] ),
  CAST ( ( SELECT ''{"infect":"'' || infect || ''", "up_date":"'' || up_date || ''", "exam_date":"'' || exam_date || ''", "infection_cd":'' || infection_cd || ''}'' FROM infectionInfo ) AS JSONB ) :: JSONB 
) ,
	up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7118, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@info_dial_diff_cd'')::text, ''is_dial_diff''::text], ''"0"'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @info_dial_diff_cd != 0', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の置換透析困難', '2022-08-05 11:01:31.872', CURRENT_TIMESTAMP, '[{"sql_cd": 7117, "field_name": "info_dial_diff_cd", "replace_var": "@info_dial_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7116, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@info_diff_cd'')::text, ''is_main''::text], ''"0"'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @info_diff_cd != 0', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の置換主透析困難', '2022-08-05 11:01:31.644', CURRENT_TIMESTAMP, '[{"sql_cd": 7115, "field_name": "info_diff_cd", "replace_var": "@info_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7113, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@ppm_info_dial_diff_cd'')::text, ''reg_date''::text], ''null'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @ppm_info_dial_diff_cd != 0', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の更新日が空です', '2022-07-07 03:07:10.117', CURRENT_TIMESTAMP, '[{"sql_cd": 7119, "field_name": "ppm_info_dial_diff_cd", "replace_var": "@ppm_info_dial_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7109, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@dial_diff_cd'')::text, ''reg_date''::text], ''@date'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @dial_diff_cd != ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正の現在の日付', '2022-07-07 03:07:10.126', CURRENT_TIMESTAMP, '[{"sql_cd": 7110, "field_name": "dial_diff_cd", "replace_var": "@dial_diff_cd"}, {"sql_cd": 7114, "field_name": "date", "replace_var": "@date"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7108, 'UPDATE pat_personal_main ppm1
 SET
  in_out_class = 2,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正', '2022-06-18 10:34:23.227', CURRENT_TIMESTAMP, '[]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7105, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@dialysis_difficulty_cd'')::text, ''is_main''::text], ''"1"'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @info_diff_cd = ''0''
	AND @dialysis_difficulty_cd != ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正', '2022-06-18 10:26:27.618', CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}, {"sql_cd": 7115, "field_name": "info_diff_cd", "replace_var": "@info_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7103, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@dialysis_difficulty_cd'')::text, ''is_dial_diff''::text], ''"1"'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @dialysis_difficulty_cd != ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7102, 'with nameSplit as (select split_part(''@otherContactInfo.lastName'' ,'' '', 1) as lastName,
                          split_part(''@otherContactInfo.lastName'' ,'' '', 2) as firstName),
     dup as (select (case when count(1) >= 1 then 1 else 0 end) as checkDup
                FROM pat_personal_main
                 CROSS JOIN jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) WITH ORDINALITY arr(j, idx), nameSplit
                    WHERE is_del = ''0''
                      AND hosp_pat_id = ''@hospPatId''
                      and (((j ->> ''first_name'')::text = nameSplit.firstName
                                   and (j ->> ''last_name'')::text = nameSplit.lastName)
                        or (j ->> ''last_name'')::text = ''@otherContactInfo.lastName''))
UPDATE pat_personal_main
SET 
	up_date = CURRENT_TIMESTAMP,
other_contact_info = (CASE
            ''@otherContactInfoFlg''
             WHEN '''' THEN
                 ''@otherContactInfoValue''
             ELSE (case when ''@otherContactInfo.relationName'' <> ''本人'' and dup.checkDup = ''0'' then other_contact_info || cast(''[
               {
                 "ctl_no": "@otherContactInfo.ctlNo",
                 "disp_order": "@otherContactInfo.dispOrder",
                 "is_key_person": "@otherContactInfo.isKeyPerson",
                 "pat_id": "@otherContactInfo.patId",
                 "last_name": "''||nameSplit.lastName||''",
                 "first_name": "''||nameSplit.firstName||''",
                 "last_name_kana": "@otherContactInfo.lastNmKana",
                 "first_name_kana": "@otherContactInfo.firstNmKana",
                 "relation_cd": ''||@relationCd||'',
                 "relation_name": "@otherContactInfo.relationName",
                 "zip_cd": "@otherContactInfo.zipCd",
                 "address": "@otherContactInfo.address",
                 "e_mail": "@otherContactInfo.eMail",
                 "work_name": "@otherContactInfo.workName",
                 "work_tel": "@otherContactInfo.workTel",
                 "tel1": "@otherContactInfo.tel1",
                 "tel2": "@otherContactInfo.tel2",
                 "fax": "@otherContactInfo.fax",
                 "memo1": "@otherContactInfo.memo1",
                 "memo2": "@otherContactInfo.memo2"
               }
             ]'' as text) :: jsonb else ''@otherContactInfoValue'' end)
            END)::jsonb,
    pat_contact_info   = (CASE
                              when
                                  ''@otherContactInfoFlg'' <> '''' and ''@otherContactInfo.relationName'' = ''本人''
                                  THEN
                                  ''
                                  {
                                    "fax": "@otherContactInfo.fax",
                                    "tel1": "@otherContactInfo.tel1",
                                    "tel2": "@otherContactInfo.tel2",
                                    "memo1": "@otherContactInfo.memo1",
                                    "memo2": "@otherContactInfo.memo2",
                                    "e_mail": "@otherContactInfo.eMail",
                                    "zip_cd": "@otherContactInfo.zipCd",
                                    "address": "@otherContactInfo.address",
                                    "work_tel": "@otherContactInfo.workTel",
                                    "work_name": "@otherContactInfo.workName",
                                    "work_address": "@otherContactInfo.workAddress"
                                  }
                                  '' :: jsonb
                              ELSE pat_contact_info
        END)
from dup,nameSplit
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 9620, "field_name": "relation_cd", "replace_var": "@relationCd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7101, 'update pat_personal_main set
	other_contact_info = ''[]'',
	up_date = CURRENT_TIMESTAMP
where
  is_del = ''0''
and
  hosp_pat_id = ''@hospPatId''
and
  facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3104, 'WITH taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録memo
 select case when staff_cd like ''%1%'' then ''1'' else ''0'' end  as taking from (
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = ''@key0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd''
    AND info ->> ''key1'' = ''ORDER_RECV''
    AND info ->> ''key2'' = ''ORDER_RECV_TAKING'')   as taking_info 
),
memo_title AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録memo
SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS memo_title
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = ''@facilityCd''
	AND is_del = ''0''
	-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
	AND COALESCE(info->>''key0'','''') = ''@key0''
	-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
	AND info ->> ''key1'' = ''ORDER_RECV''
	AND info ->> ''key2'' = ''ORDER_RECV_MEMO_TITLE''
)
, memo_id_info AS (
  -- 患者メモの番号:患者メモの番号(1~20を設定する、初期値は1)
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS memo_id 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(ini_info->>''key0'','''') = ''@key0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_MEMO_ID'' 
  UNION 
  SELECT
    2 AS order_no
    , ''20'' AS memo_id
  ORDER BY
    order_no ASC LIMIT 1
)
, mstInitInfo AS ( 
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , ms->>''ctl_no'' AS ctl_no 
    , ms->>''title'' AS title 
    , ms->>''content'' AS content 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.pat_memo_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND (ms->>''ctl_no''::TEXT) = (SELECT memo_id FROM memo_id_info) -- 患者メモの番号が有り
    AND (SELECT taking FROM taking_info) = ''1'' -- 取込先指定＝「1：患者メモ」
--     AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  UNION 
  SELECT
    2 AS order_no
    , (idx - 1) AS idx
    , ms ->> ''ctl_no'' AS ctl_no 
    , ms ->> ''title'' AS title 
    , ms ->> ''content'' AS content 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.pat_memo_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND (ms->>''ctl_no''::TEXT) = ''1'' -- 患者メモの番号[1]が有り
    AND (SELECT taking FROM taking_info) = ''1'' -- 取込先指定＝「1：患者メモ」
--     AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  ORDER BY order_no ASC LIMIT 1
),
-- memo_info AS (
-- select
-- case when 
-- (memo_info ->> ''title'') = (select taking_title from taking_title_info)
-- then (memo_info ->> ''content'')::text
-- else '''' end as memo
-- from pat_main  pm
--  CROSS JOIN LATERAL json_array_elements(pm.pat_memo_info ::json) AS memo_info 
-- where 
--      pat_id = @patId
-- AND  facility_cd = ''@facilityCd''
-- AND  memo_info ->> ''ctl_no'' = (SELECT memo_id FROM memo_id_info)
-- AND  is_del = ''0'' 
-- )
 mstInfo AS (
  SELECT
		idx,
	 ctl_no,
    (select memo_title from memo_title)::text AS title ,
		REPLACE(''@patMemoInfo.content'','' 【'',''\n【'')
     AS content
		 from mstInitInfo
)
UPDATE pat_main 
SET pat_memo_info = jsonb_set (
  COALESCE ( pat_memo_info, ''[]'' ) :: JSONB,
  CAST ( ( SELECT ''{'' || idx || ''}'' FROM mstInfo ) AS TEXT [] ),
  CAST ( ( SELECT ''{"ctl_no":'' || ctl_no || '', "title":"'' || title || ''", "content":"'' || content || ''"}'' FROM mstInfo ) AS JSONB ) :: JSONB 
) ,
	up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND (SELECT content FROM mstInfo) IS NOT NULL', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→患者メモ', '2022-03-14 14:46:10.256', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3103, 'WITH mstInfo AS ( 
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , (ms ->> ''cd''::TEXT) AS cd 
    , (''1''::TEXT) AS is_enable 
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') AS reg_date
    , (ms ->> ''start_date''::TEXT) AS start_date
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.addition_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND ms ->> ''cd'' :: TEXT = ''@additionInfo.cd''
  UNION
  SELECT
    2 AS order_no
    , NULL AS idx
    , (''@additionInfo.cd''::TEXT) AS cd 
    , (''1''::TEXT) AS is_enable 
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') AS reg_date
    , NULL AS start_date
  ORDER BY order_no ASC LIMIT 1
) 
UPDATE pat_main 
SET addition_info = jsonb_set (
  COALESCE ( addition_info, ''[]'' ) :: JSONB,
  CAST((SELECT ''{'' ||  COALESCE(idx, 999) || ''}'' FROM mstInfo) AS TEXT []),
  (SELECT jsonb_build_object(''cd'', TO_NUMBER(cd, ''FM999999999999999999''), ''reg_date'', reg_date, ''is_enable'', is_enable, ''start_date'', start_date) FROM mstInfo) :: JSONB 
) ,
	up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→加算情報', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3100, 'with markedData as (select coalesce(nullif(jsonb_agg(t1.t0), null), ''[]'') as data
                    from (select jsonb_array_elements(charge_staff_info) as t0
                          from pat_main
                          where is_del = ''0''
                            AND pat_id = @patId
                            AND facility_cd = ''@facilityCd'') as t1
                    where t1.t0 ->> ''flg'' = ''doc''
                      and t1.t0 ->> ''staff_cd'' <> ''-999999''),
     unmarkedData as (select coalesce(nullif(jsonb_agg(t1.t0), null), ''[]'') as data
                      from (select jsonb_array_elements(charge_staff_info) as t0
                            from pat_main
                            where is_del = ''0''
                              AND pat_id = @patId
                              AND facility_cd = ''@facilityCd'') as t1
                      where t1.t0 ->> ''ctl_no'' not in (select t1.t0 ->> ''ctl_no''
                                                       from (select jsonb_array_elements(charge_staff_info) as t0
                                                             from pat_main
                                                             where is_del = ''0''
                                                               AND pat_id = @patId
                                                               AND facility_cd = ''@facilityCd'') as t1
                                                       where t1.t0 ->> ''flg'' = ''doc''
                                                         or t1.t0 ->> ''staff_cd'' = ''-999999''))
update pat_main
set charge_staff_info = (select jsonb_agg(t3.jList)
                         from (select jsonb_delete(t2.list, ''flg'') as jList
                               from (select jsonb_array_elements(unmarkedData.data || markedData.data) as list
                                     from markedData,
                                          unmarkedData) as t2
                               order by t2.list ->> ''disp_order'' asc) t3),
	up_date = CURRENT_TIMESTAMP
where is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd'';', 2, '[{}]', '0', '{"applications": [4]}', NULL, '', '2022-11-16 13:47:00.648', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2107, 'with nowData as (select jsonb_agg((exam_result_info ->> (idx - 1)::int)::json) as nowJosn
                 from pat_exam_main
                          CROSS JOIN jsonb_array_elements(exam_result_info) WITH ORDINALITY arr(j, idx)
                 WHERE ((j ->> ''result'') IS NOT NULL OR (j ->> ''com_cd'') IS NOT NULL OR (j ->> ''freememo'') IS NOT NULL)
                   and is_del = ''0''
                   and pat_id = @patId
                   and facility_cd = ''@facilityCd''
                   and exam_main_cd = @examMainCd)
update pat_exam_main
set exam_result_info = nowData.nowJosn,
	up_date = CURRENT_TIMESTAMP
from nowData
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and exam_main_cd = @examMainCd ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2022-08-15 11:33:51.609', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2106, 'WITH result_comment1 AS (
  SELECT
    0 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), (''結果コメント１コード[@examResultInfo.resultComment1Code]'')) 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS comment_text 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(ini_info->>''key0'','''') = ''@key0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''EXAM_COMMENT_CODE'' 
    AND TRIM(ini_info ->> ''key2'') = ''@examResultInfo.resultComment1Code'' 
    AND '''' <> ''@examResultInfo.resultComment1Code''
  UNION
  SELECT
    1 AS order_no
    , ''結果コメント１コード[@examResultInfo.resultComment1Code]'' AS comment_text
  WHERE
    '''' <> ''@examResultInfo.resultComment1Code''
  ORDER BY order_no ASC LIMIT 1
) 
, result_comment2 AS ( 
  SELECT
    0 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), (''結果コメント２コード[@examResultInfo.resultComment2Code]'')) 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS comment_text 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(ini_info->>''key0'','''') = ''@key0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''EXAM_COMMENT_CODE'' 
    AND TRIM(ini_info ->> ''key2'') = ''@examResultInfo.resultComment2Code'' 
    AND '''' <> ''@examResultInfo.resultComment2Code''
  UNION
  SELECT
    1 AS order_no
    , ''結果コメント２コード[@examResultInfo.resultComment2Code]'' AS comment_text
  WHERE
    '''' <> ''@examResultInfo.resultComment2Code''
  ORDER BY order_no ASC LIMIT 1
) 
, examin_get_info AS ( 
  SELECT
    0 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS examin_get_flag 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(ini_info->>''key0'','''') = ''@key0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''EXAMIN_GET_DESTINATION'' 
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS examin_get_flag
  ORDER BY order_no ASC LIMIT 1
) 
, freememo_info_join_0 AS ( 
  SELECT
    0 AS order_no
    , ''@examResultInfo.freememo'' AS freememo_text 
  UNION 
  SELECT
    1 AS order_no
    , (SELECT comment_text FROM result_comment1) AS freememo_text 
  UNION 
  SELECT
    2 AS order_no
    , (SELECT comment_text FROM result_comment2) AS freememo_text 
  ORDER BY
    order_no ASC
) 
, result_freememo_info AS ( 
  -- 0:電文.検査結果
  SELECT
    ''@examResultInfo.result'' AS result
    , (SELECT STRING_AGG(freememo_text, '','') AS freememo FROM freememo_info_join_0 WHERE NULLIF(freememo_text, '''') IS NOT NULL) AS freememo
  WHERE
    (SELECT examin_get_flag FROM examin_get_info) = ''0''
  -- 1:電文.検査結果フリー
  UNION 
  SELECT
    -- Ⅰ)検査結果フリーに値がある場合
    CASE WHEN ''@examResultInfo.freememo'' != '''' 
           THEN ''@examResultInfo.freememo'' 
         -- Ⅱ)検査結果フリーに値がなく、検査結果と結果コメント１コードのいずれにも値がある場合
         WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
           THEN ''@examResultInfo.result'' || (SELECT comment_text FROM result_comment1)
         -- Ⅲ) 検査結果フリーに値がなく、検査結果のみに値がある場合
         WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NULL
           THEN ''@examResultInfo.result''
         -- Ⅳ) 検査結果フリーに値がなく、結果コメント１コードのみに値がある場合
         WHEN ''@examResultInfo.result'' ='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
           THEN ''''
         ELSE ''''
         END AS result
    , CASE WHEN ''@examResultInfo.freememo'' != '''' 
             THEN '''' 
           WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
             THEN '''' 
           WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NULL
             THEN '''' 
           WHEN ''@examResultInfo.result'' ='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
             THEN (SELECT comment_text FROM result_comment1)
         ELSE ''''
         END AS freememo
  WHERE
    (SELECT examin_get_flag FROM examin_get_info) != ''0''
) 
, mstInfo AS ( 
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , ms->>''item_cd'' AS item_cd 
    , ms->>''item_name'' AS item_name 
    , ms->>''type'' AS type 
    , ms->>''unit'' AS unit 
    , ms->>''exam_class'' AS exam_class 
    , ms->>''normal_value_upper'' AS upper 
    , ms->>''normal_value_lower'' AS lower 
    , ms->>''com_cd'' AS com_cd 
    , ms->>''disp_order'' AS disp_order 
    , NULLIF(''@examResultInfo.hl'', '''') AS hl
    , NULLIF((SELECT result FROM result_freememo_info), '''') AS result
    , NULLIF((SELECT freememo FROM result_freememo_info), '''') AS freememo
    , TO_CHAR(TO_TIMESTAMP(NULLIF(''@examResultInfo.resultDate'', ''''), ''YYYYMMDDHH24MISS''), ''YYYY/MM/DD HH24:MI:SS'') AS result_date
  FROM
    pat_exam_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.exam_result_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND exam_main_cd = @examMainCd 
    AND ms->>''item_cd'' :: TEXT = ''@examResultInfo.itemCd''
  UNION
  SELECT
    2 AS order_no
    , NULL AS idx
    , (A.exam_item_cd :: TEXT) AS item_cd
    , A.exam_item_name AS item_name
    , A.data_type AS type
    , A.unit
    , A.exam_class
    , A.input_upper AS upper
    , A.input_lower AS lower
    , null AS com_cd
    , NULLIF(''@nextDispOrder'', '''') AS disp_order
    , NULLIF(''@examResultInfo.hl'', '''') AS hl
    , NULLIF((SELECT result FROM result_freememo_info), '''') AS result
    , NULLIF((SELECT freememo FROM result_freememo_info), '''') AS freememo
    , TO_CHAR(TO_TIMESTAMP(NULLIF(''@examResultInfo.resultDate'', ''''), ''YYYYMMDDHH24MISS''), ''YYYY/MM/DD HH24:MI:SS'') AS result_date
  FROM
    mst_exam_item A
  WHERE
    A.exam_item_cd = TO_NUMBER(''@examResultInfo.itemCd'', ''FM999999999999999999'')
  ORDER BY order_no ASC LIMIT 1
) 
, do_middle_check_data AS (
    SELECT COUNT(*) AS resultDeleteFalg
    FROM (
        SELECT result, NULLIF(com_cd, '''') AS com_cd, freememo
        FROM mstInfo
        WHERE result <> '''' OR NULLIF(com_cd, '''') <> '''' OR freememo <> '''') AS middleData 
)
UPDATE pat_exam_main 
SET exam_result_info = jsonb_set(
  COALESCE(exam_result_info, ''[]'') :: JSONB,
  CAST((SELECT ''{'' || COALESCE(idx, 999) || ''}'' FROM mstInfo ) AS TEXT []),
  (SELECT jsonb_build_object(''item_cd'', TO_NUMBER(item_cd, ''FM999999999999999999'')
          , ''item_name'' , NULLIF(item_name, '''')
          , ''type'' , TO_NUMBER(NULLIF(type, ''''), ''FM999999999999999999'') 
          , ''unit'' , NULLIF(unit, '''')
          , ''exam_class'' , NULLIF(exam_class, '''')
          , ''upper'' , TO_NUMBER(NULLIF(upper, ''''), ''FM999999999999999999'')
          , ''lower'' , TO_NUMBER(NULLIF(lower, ''''), ''FM999999999999999999'')
          , ''com_cd'' , NULLIF(com_cd, '''')
          , ''disp_order'' , TO_NUMBER(NULLIF(disp_order, ''''), ''FM999999999999999999'') 
          , ''hl'' , NULLIF(hl, '''')
          , ''result'' , mstInfo.result
          , ''freememo'' , NULLIF(freememo, '''')
          , ''result_date'' , NULLIF(result_date, '''')) FROM mstInfo) :: JSONB 
) ,
	up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND exam_main_cd = @examMainCd ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2022-08-15 11:33:51.609', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1999, 'update pat_personal_main 
set transport_cd = (case when ''@transportCd'' = '''' then null else ''@transportCd'' end)::integer,
	up_date = CURRENT_TIMESTAMP
where
  pat_id = @patId', 3, '[{}]', '0', '{"applications": [4]}', NULL, '（送信用）日機裝）profile：profile連携（XML）で受信した詳細情報（搬送区分）', '2022-06-23 03:50:33.382', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1890, 'update pat_main set
in_out_current_state = 11,
	up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
 ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日机装 profile', '2022-06-21 12:42:16.371', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1887, 'WITH die_info AS (
  SELECT 
    COALESCE(NULLIF(''@isDie'', ''''), ''0'') AS is_die
    , TO_TIMESTAMP(NULLIF(''@dieDate_Date'', ''''), ''YYYY-MM-DD HH24:MI:SS'') AS die_date
)
UPDATE pat_personal_main 
SET
  in_out_class = ''2'',
	up_date = CURRENT_TIMESTAMP
WHERE
  facility_cd = ''@facilityCd'' 
  AND hosp_pat_id = ''@hospPatId'' 
  AND pat_id = @patId ', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日机装 profile', '2022-06-21 12:42:16.371', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1885, 'update pat_unique set
in_out_visit_history_info = ''[{"ctl_no": 1, "in_out": 2, "reason": null, "to_course": null, "to_doctor": null, "disp_order": 0, "period_end": null, "facility_cd": "999998", "from_course": null, "from_doctor": null, "move_in_out": "11", "to_facility": null, "period_start": "@dieDate", "from_facility": null, "course_is_free": "0", "doctor_is_free": "0", "period_end_day": null, "period_end_year": null, "facility_is_free": "0", "period_end_month": null, "period_start_day": "01", "period_start_date": null, "period_start_year": "2022", "period_start_month": "06", "period_end_input_free": "0", "period_start_input_free": "0", "to_medicalInstitutionCd": null, "from_medicalInstitutionCd": null}, {"ctl_no": 2, "in_out": 1, "reason": null, "to_course": null, "to_doctor": null, "disp_order": 0, "period_end": null, "facility_cd": "999998", "from_course": null, "from_doctor": null, "move_in_out": "4", "to_facility": null, "period_start": "20100101", "from_facility": null, "course_is_free": "0", "doctor_is_free": "0", "period_end_day": null, "period_end_year": null, "facility_is_free": "0", "period_end_month": null, "period_start_day": "01", "period_start_date": "20100101", "period_start_year": "2010", "period_start_month": "01", "period_end_input_free": "0", "period_start_input_free": "0", "to_medicalInstitutionCd": null, "from_medicalInstitutionCd": null}]'',
	up_date = CURRENT_TIMESTAMP
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''	', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日机装 profile', '2022-06-21 12:42:16.371', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1881, 'with currentTime as (select to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'') as nowDate)
update pat_unique
set 
	up_date = CURRENT_TIMESTAMP,
medical_hst_info = COALESCE(nullif(medical_hst_info::text, '' ''), ''[]'')::jsonb ||
    cast(''[{"memo":null, "ctl_no":null, "die_date": "@dieDate", "out_come": "10", "course_cd":null, "is_notice":null, "disease_cd":null, "disp_order":null, "disease_day":null, "facility_cd":null, "disease_date":null, "disease_year":null, "is_diagnosed":null, "diagnosis_day":null, "disease_month":null, "out_come_date": "'' ||
         currentTime.nowDate ||
         ''", "course_is_free":null, "diagnosis_date":null, "diagnosis_year":null, "diagnosis_month":null, "is_main_disease":null, "diagnostician_cd":null, "diagnosis_facility_cd":null, "diagnostician_is_free":null, "is_confirmation_biopsy":null, "diagnosis_facility_is_free":null, "is_dialysis_underlying_disease":null}]'' as text)::jsonb
from currentTime
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and is_del = ''0'';', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_生存情報', '2022-06-20 11:45:57.492', CURRENT_TIMESTAMP, '[]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1802, 'WITH check_taboo_allergy_cd as (select (case position('','' in ''@tabooAllergyInfo.tabooAllergyCd'')
                                            when 0 then false
                                            else true end) as ctac)
   , tabooAllergyCdInfo AS (SELECT (case
                                        when ctac then split_part(''@tabooAllergyInfo.tabooAllergyCd'', '','', 1)
                                        else '''' end)                                 AS cd
                                 , (case
                                        when ctac then split_part(''@tabooAllergyInfo.tabooAllergyCd'', '','', 2)
                                        else ''5'' end)                                AS type
                                 , (case
                                        when ctac then split_part(''@tabooAllergyInfo.tabooAllergyCd'', '','', 3)
                                        else ''@tabooAllergyInfo.tabooAllergyCd'' end) AS hospital_cd
                            from check_taboo_allergy_cd)
   , newTabooAllergyInfo AS (SELECT ''【分類】'' || (CASE type
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
                                                     ELSE ''【マスタ一致】連携コード（'' END) || hospital_cd || ''）''::TEXT AS memo
                                  , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''1'')            AS ctl_no
                                  , ''@tabooAllergyInfo.content''::TEXT                   AS content
                                  , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'')            AS disp_order
                                  , ''@tabooAllergyInfo.categoryClass''::TEXT             AS category_class
                                  , cd                                                  AS taboo_allergy_cd
                                  , ''@tabooAllergyInfo.tabooAllergyClass''::TEXT         AS taboo_allergy_class
                             FROM tabooAllergyCdInfo)
   , tabooAllergyInfo AS (SELECT 0                                                                        AS order_no
                               , (idx - 1)                                                                AS idx
                               , REPLACE(ms ->> ''memo'', CHR(10), ''\n'') AS memo
                               , ms ->> ''ctl_no''                                                          AS ctl_no
                               , ms ->> ''content''                                                         AS content
                               , ms ->> ''disp_order''                                                      AS disp_order
                               , ms ->> ''category_class''                                                  AS category_class
                               , ms ->> ''taboo_allergy_cd''                                                AS taboo_allergy_cd
                               , ms ->> ''taboo_allergy_class''                                             AS taboo_allergy_class
                          FROM pat_main AS A
                                   CROSS JOIN LATERAL jsonb_array_elements(A.taboo_allergy_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
                                   INNER JOIN newTabooAllergyInfo AS new
                                              ON (ms ->> ''taboo_allergy_cd'' <> '''' and new.taboo_allergy_cd = ms ->> ''taboo_allergy_cd'') or
                                                 (ms ->> ''taboo_allergy_cd'' = '''' and new.content = ms ->> ''content'')
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
UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
taboo_allergy_info = jsonb_set(COALESCE(taboo_allergy_info, ''[]'') ::JSONB
    , CAST((SELECT ''{'' || COALESCE(idx, 999) || ''}'' FROM tabooAllergyInfo) AS TEXT[])
    , jsonb_build_object(''memo'', memo,
                      ''ctl_no'', ctl_no::integer,
                      ''content'', content,
                      ''disp_order'', disp_order::integer,
                      ''category_class'', category_class,
                      ''taboo_allergy_cd'', nullif(taboo_allergy_cd, ''''),
                      ''taboo_allergy_class'', taboo_allergy_class))
from tabooAllergyInfo
WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通__禁忌・アレルギー情報_更新', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1502, 'WITH die_info AS (
  SELECT 
    COALESCE(NULLIF(''@isDie'', ''''), ''0'') AS is_die
    , TO_TIMESTAMP(NULLIF(''@dieDate_Date'', ''''), ''YYYY-MM-DD HH24:MI:SS'') AS die_date
)
UPDATE pat_personal_main 
SET
  in_out_class =  CASE (SELECT is_die FROM die_info)
    WHEN ''0'' THEN in_out_class 
    ELSE ''2''
    END 
  , is_die = (SELECT is_die FROM die_info)
  , die_date = CASE (SELECT is_die FROM die_info)
    WHEN ''0'' THEN NULL 
    ELSE (SELECT die_date FROM die_info)
    END ,
	up_date = CURRENT_TIMESTAMP
WHERE
  facility_cd = ''@facilityCd'' 
  AND hosp_pat_id = ''@hospPatId'' 
  AND pat_id = @patId ', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_生存の有無登録', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1210, 'WITH take_cource_info AS (SELECT 1 AS order_no
                               , CASE TRIM(ini_info ->> ''value'')
                                     WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'')
                                     ELSE TRIM(ini_info ->> ''value'')
        END                        AS take_cource_flg
                          FROM mst_coop_ini AS ini
                                   CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
                          WHERE ini.is_del = ''0''
                            AND ini.facility_cd = ''@facilityCd''
														AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
                            AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML''
                            AND TRIM(ini_info ->> ''key2'') = ''IND_DOCTOR_FLG''
                          UNION
                          SELECT 2   AS order_no
                               , ''0'' AS take_cource_flg
                          ORDER BY order_no ASC
                          LIMIT 1),
     noForDoc as (select count(1) + 1 as counts
                  from (select jsonb_array_elements(charge_staff_info) as t0
                        from pat_main
                        where pat_id = @patId) as t1
                  where t1.t0 ->> ''flg'' = ''doc''),
     noForNur as (select (case
                              when take_cource_info.take_cource_flg = ''0'' then c + 3
                              when take_cource_info.take_cource_flg = ''1'' then c + 2 end) as counts
                  from (select count(1) as c
                        from (select jsonb_array_elements(charge_staff_info) as t0
                              from pat_main
                              where pat_id = @patId) as t1
                        where t1.t0 ->> ''flg'' = ''nur'') as t2,
                       take_cource_info),
     countAll as (select coalesce(nullif(max(t1.t0 ->> ''disp_order''), '''')::integer, 0) as counts
                  from (select jsonb_array_elements(charge_staff_info) as t0
                        from pat_main
                        where pat_id = @patId) as t1),
     dispOrderForDoc as (select coalesce((select nullif(info ->> ''disp_order'', '''')
                                          from pat_main,
                                               noForDoc
                                                   CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                                          where pat_id = @patId
                                            and info ->> ''ctl_no'' = cast(noForDoc.counts as text)
                                            and info ->> ''flg'' is null),
                                         cast((countAll.counts + 1) as text)) as dispOrder
                         from countAll),
     dispOrderForNur as (select coalesce((select nullif(info ->> ''disp_order'', '''')
                                          from pat_main,
                                               noForNur
                                                   CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                                          where pat_id = @patId
                                            and info ->> ''ctl_no'' = cast(noForNur.counts as text)
                                            and info ->> ''flg'' is null),
                                         cast((countAll.counts + 1) as text)) as dispOrder
                         from countAll),
     changeStatusForDoc as (select 1                                     as no,
                                   coalesce(info ->> ''is_charge'', ''0'')   as isCharge,
                                   coalesce(info ->> ''is_puncture'', ''0'') as isPuncture
                            from pat_main,
                                 noForDoc
                                     CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                            where pat_id = @patId
                              and info ->> ''ctl_no'' = cast(noForDoc.counts as text)
                            union
                            select 2 as no, ''0'' as isCharge, ''0'' as isPuncture
                            order by no
                            limit 1),
     changeStatusForNur as (select 1                                     as no,
                                   coalesce(info ->> ''is_charge'', ''0'')   as isCharge,
                                   coalesce(info ->> ''is_puncture'', ''0'') as isPuncture
                            from pat_main,
                                 noForNur
                                     CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                            where pat_id = @patId
                              and info ->> ''ctl_no'' = cast(noForNur.counts as text)
                            union
                            select 2 as no, ''0'' as isCharge, ''0'' as isPuncture
                            order by no
                            limit 1),
     checkStaffCode as (select (case ''@chargeStaffInfo.staffCd''
                                    when '''' then ''-999999''
                                    else ''@chargeStaffInfo.staffCd'' end) as staffCode),
     checkIndicatorStaffCode as (select (case ''@chargeStaffInfo.indicatorStaffCd''
                                             when '''' then ''-999999''
                                             else ''@chargeStaffInfo.indicatorStaffCd'' end) as staffCode),
     checkFortest as (select ''@check'' as check)
UPDATE pat_main
SET 
	up_date = CURRENT_TIMESTAMP,
charge_staff_info =
        CASE ''@chargeStaffInfoFlg''
            WHEN ''''
                THEN ''@chargeStaffInfoValue''
            ELSE (case
                      when take_cource_info.take_cource_flg = ''0'' and
                           ''@chargeStaffInfo.staffCd'' <> ''@'' || ''chargeStaffInfo.staffCd''
                          then (case
                                    when ''@chargeStaffInfo.isMain'' = ''1'' and ''@chargeStaffInfo.isCharge'' = ''0'' and
                                         noForDoc.counts < 3 then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || noForDoc.counts || '',
                          "disp_order": "'' || dispOrderForDoc.dispOrder || ''",
                          "staff_cd": '' || checkStaffCode.staffCode || '',
                          "is_main": "1",
                          "is_charge": "'' || changeStatusForDoc.isCharge || ''",
                          "is_puncture": "'' || changeStatusForDoc.isPuncture || ''",
                          "flg":"doc"
                        }
                      ]'' as text) :: jsonb
                                    when ''@chargeStaffInfo.isMain'' = ''0'' and ''@chargeStaffInfo.isCharge'' = ''1'' and
                                         noForNur.counts < 5 then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || noForNur.counts || '',
                          "disp_order": "'' || dispOrderForNur.dispOrder || ''",
                          "staff_cd": '' || checkStaffCode.staffCode || '',
                          "is_main": "0",
                          "is_charge": "1",
                          "is_puncture": "'' || changeStatusForNur.isPuncture || ''",
                          "flg":"nur"
                        }
                      ]'' as text) :: jsonb
                                    else charge_staff_info end)
                      when take_cource_info.take_cource_flg = ''1''
                          then (case
                                    when noForDoc.counts = 1 and ''@chargeStaffInfo.indicatorStaffCd'' <> ''@''||''chargeStaffInfo.indicatorStaffCd'' then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": 1,
                          "disp_order": "'' || dispOrderForDoc.dispOrder || ''",
                          "staff_cd": '' || checkIndicatorStaffCode.staffCode || '',
                          "is_main": "1",
                          "is_charge": "'' || changeStatusForDoc.isCharge || ''",
                          "is_puncture": "'' || changeStatusForDoc.isPuncture || ''",
                          "flg":"doc"
                        }
                      ]'' as text) :: jsonb
                                    when ''@chargeStaffInfo.isMain'' = ''0'' and ''@chargeStaffInfo.isCharge'' = ''1'' and
                                         ''@chargeStaffInfo.staffCd'' <> ''@'' || ''chargeStaffInfo.staffCd'' and
                                         noForNur.counts < 4 then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || noForNur.counts || '',
                          "disp_order": "'' || dispOrderForNur.dispOrder || ''",
                          "staff_cd": '' || checkStaffCode.staffCode || '',
                          "is_main": "0",
                          "is_charge": "1",
                          "is_puncture": "'' || changeStatusForNur.isPuncture || ''",
                          "flg":"nur"
                        }
                      ]'' as text) :: jsonb
                                    else charge_staff_info end)
                      else charge_staff_info END) END
from take_cource_info,
     noForDoc,
     noForNur,
     checkStaffCode,
     checkIndicatorStaffCode,
     dispOrderForDoc,
     dispOrderForNur,
     changeStatusForDoc,
     changeStatusForNur
WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の修正', '2022-06-13 02:07:03.922', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1209, 'with markedData as (select coalesce(nullif(jsonb_agg(t1.t0), null), ''[]'') as data
                    from (select jsonb_array_elements(charge_staff_info) as t0
                          from pat_main
                          where is_del = ''0''
                            AND pat_id = @patId
                            AND facility_cd = ''@facilityCd'') as t1
                    where t1.t0 ->> ''flg'' in (''doc'', ''nur'')
                      and t1.t0 ->> ''staff_cd'' <> ''-999999''),
     unmarkedData as (select coalesce(nullif(jsonb_agg(t1.t0), null), ''[]'') as data
                      from (select jsonb_array_elements(charge_staff_info) as t0
                            from pat_main
                            where is_del = ''0''
                              AND pat_id = @patId
                              AND facility_cd = ''@facilityCd'') as t1
                      where t1.t0 ->> ''ctl_no'' not in (select t1.t0 ->> ''ctl_no''
                                                       from (select jsonb_array_elements(charge_staff_info) as t0
                                                             from pat_main
                                                             where is_del = ''0''
                                                               AND pat_id = @patId
                                                               AND facility_cd = ''@facilityCd'') as t1
                                                       where t1.t0 ->> ''flg'' in (''doc'', ''nur'')
                                                         or t1.t0 ->> ''staff_cd'' = ''-999999''))
update pat_main
set charge_staff_info = (select jsonb_agg(t3.jList)
                         from (select jsonb_delete(t2.list, ''flg'') as jList
                               from (select jsonb_array_elements(unmarkedData.data || markedData.data) as list
                                     from markedData,
                                          unmarkedData) as t2
                               order by t2.list ->> ''disp_order'' asc) t3),
	up_date = CURRENT_TIMESTAMP
where is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd'';', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の新規', '2022-06-17 06:29:02.276', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1104, 'UPDATE pat_personal_main
SET 
  primary_disease_cd = (NULLIF(''@primaryDiseaseCd'', '''') :: INTEGER),
	up_date = CURRENT_TIMESTAMP
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId
  AND is_del = ''0''
  AND ''@upBaseDiseaseFlg'' = ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)患者個人情報→原疾患コードの設定', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1054, 'UPDATE pat_main pm1
 SET
  pat_memo_info = 
	CASE
    ''@patMemoInfo.title'' 
    WHEN '''' THEN
    ''@patMemoInfoValue''
ELSE	jsonb_set(pat_memo_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main pm2, jsonb_array_elements(pat_memo_info) WITH

ORDINALITY WHERE pm1.pat_id = pm2.pat_id AND value->>''ctl_no'' = ''@no'')::text, ''title''::text], ''"@patMemoInfo.title"'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
	AND @no < 12
	AND @no > 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者メモ2のタイトルの修正', '2022-06-17 13:05:27.576', CURRENT_TIMESTAMP, '[{"sql_cd": 1055, "field_name": "no", "replace_var": "@no"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1053, 'UPDATE pat_main pm1
 SET
  pat_memo_info = 
	CASE
    ''@patMemoInfo.content''
    WHEN '''' THEN
    ''@patMemoInfoValue''
ELSE	jsonb_set(pat_memo_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main pm2, jsonb_array_elements(pat_memo_info) WITH

ORDINALITY WHERE pm1.pat_id = pm2.pat_id AND value->>''ctl_no'' = ''@no'')::text, ''content''::text], ''"@patMemoInfo.content"'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
	AND @no < 12
	AND @no > 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者メモ2の内容の修正', '2022-06-17 13:05:27.576', CURRENT_TIMESTAMP, '[{"sql_cd": 1055, "field_name": "no", "replace_var": "@no"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1052, 'UPDATE pat_main pm1
 SET
  pat_memo_info = 
	CASE
    ''@patMemoInfo.content'' 
    WHEN '''' THEN
    ''@patMemoInfoValue''
ELSE	jsonb_set(pat_memo_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main pm2, jsonb_array_elements(pat_memo_info) WITH

ORDINALITY WHERE pm1.pat_id = pm2.pat_id AND value->>''ctl_no'' = ''1'')::text, ''content''::text], ''"@patMemoInfo.content"'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者メモ1の内容の修正', '2022-06-17 13:05:27.576', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1050, 'UPDATE pat_main pm1
 SET
  pat_memo_info = 
	CASE
    ''@patMemoInfo.title'' 
    WHEN '''' THEN
    ''@patMemoInfoValue''
ELSE	jsonb_set(pat_memo_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_main pm2, jsonb_array_elements(pat_memo_info) WITH

ORDINALITY WHERE pm1.pat_id = pm2.pat_id AND value->>''ctl_no'' = ''1'')::text, ''title''::text], ''"@patMemoInfo.title"'') 
 END,
	up_date = CURRENT_TIMESTAMP
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者メモの修正', '2022-06-11 07:38:42.336', CURRENT_TIMESTAMP, NULL);
