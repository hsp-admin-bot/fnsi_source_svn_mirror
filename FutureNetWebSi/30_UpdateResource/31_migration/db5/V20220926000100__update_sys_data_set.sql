delete from ntss.sys_data_set where sql_cd = '9627';
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
			CASE WHEN EXISTS(SELECT jTbl.* FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) jTbl WHERE pat_id = @patId AND value like ''%"memo": "【分類】薬剤アレルギー%'' AND value like ''%"taboo_allergy_cd": ""%'' AND value like ''%"content": "@tabooAllergyInfo.content"%'') THEN
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
			CASE WHEN EXISTS(SELECT jTbl.* FROM pat_main, jsonb_array_elements_text(taboo_allergy_info) jTbl, mstRec WHERE pat_id = @patId AND value like ''%"memo": "【分類】薬剤アレルギー%'' AND value like concat(concat(''%"taboo_allergy_cd": "'', (select seq from mstRec)), ''"%'')) THEN
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
