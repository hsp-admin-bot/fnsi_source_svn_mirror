DELETE FROM "ntss"."sys_data_set" where sql_cd in (149,150,151,230);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (149, 'WITH mst_equi AS (
	SELECT
		equipment_cd,
		equipment_name
	FROM
		mst_equipment
	WHERE
		facility_cd = @facilityCd
),
mst_equic AS (
	SELECT
		class_cd,
		class_name
	FROM
		mst_equipment_class
	WHERE
		facility_cd = @facilityCd
),
mst_medi AS (
	SELECT
		medicine_cd,
		medicine_name
	FROM
		mst_medicine
	WHERE
		facility_cd = @facilityCd
),
mst_medic AS (
	SELECT
		class_cd,
		class_name
	FROM
		mst_medicine_class
	WHERE
		facility_cd = @facilityCd
),
mst_medim AS (
	SELECT
		medicine_mix_cd,
		medicine_mix_name
	FROM
		mst_medicine_mix
	WHERE
		facility_cd = @facilityCd
),
mst_dial AS (
	SELECT
		dialyzer_cd,
		model_number
	FROM
		mst_dialyzer
	WHERE
		facility_cd = @facilityCd
)

SELECT
	supplies_cd,
	supplies_class,
	CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN supplies_cd
	END AS equipment_cd,
	CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'',''01'') THEN supplies_cd
	END AS medicine_cd,
	CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN equipment_name
		   WHEN supplies_class IN (''08'',''09'',''10'',''12'') THEN medicine_name
		   WHEN supplies_class IN (''13'',''17'') THEN medicine_mix_name
		   WHEN supplies_class IN (''01'') THEN model_number
	END AS supplies_name,
	CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd
		   ELSE ''-1''
	END AS class_cd,
	CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN mec.class_name
	     WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN mmc.class_name
	     WHEN supplies_class IN (''01'') THEN ''ダイアライザ''
			 END AS class_name,
	supplies_base_date,
	ind_rst_value
FROM
	ord_material_save oms
LEFT JOIN mst_equi me ON oms.supplies_cd::INTEGER = me.equipment_cd
LEFT JOIN mst_equic mec ON oms.class_cd::INTEGER = mec.class_cd
LEFT JOIN mst_medi mm ON oms.supplies_cd::INTEGER = mm.medicine_cd
LEFT JOIN mst_medic mmc ON oms.class_cd::INTEGER = mmc.class_cd
LEFT JOIN mst_medim mmm ON oms.supplies_cd::INTEGER = mmm.medicine_mix_cd
LEFT JOIN mst_dialyzer md ON oms.supplies_cd::INTEGER = md.dialyzer_cd
WHERE
	pat_id in (@patIds)
AND oms.facility_cd = @facilityCd
AND supplies_base_no in (@ordNos)
AND supplies_base_date::TIMESTAMP BETWEEN date_trunc(''day'', @fromDate ::timestamp) AND date_trunc(''day'', @toDate ::timestamp)
AND	ind_rst_class = ''1''
AND supplies_class <> ''16''
AND supplies_class <> ''23''
AND supplies_class <> ''24''
AND CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN
					 CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd::INTEGER IN (@eqIds)
					 ELSE -1 IN (@eqIds)
					 END
		     WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN
					 CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd::INTEGER IN (@medIds)
					 ELSE -1 IN (@medIds)
					 END
		     WHEN supplies_class IN (''01'') THEN supplies_cd::INTEGER IN (@diaIds)
	  END
ORDER BY
	CASE supplies_class
		WHEN ''01'' THEN 1  
		WHEN ''00'' THEN 2  
		WHEN ''02'' THEN 2  
		WHEN ''03'' THEN 2  
		WHEN ''04'' THEN 2  
		WHEN ''05'' THEN 2  
		WHEN ''06'' THEN 2  
		WHEN ''07'' THEN 2  
		WHEN ''11'' THEN 2  
		WHEN ''13'' THEN 3  
		WHEN ''17'' THEN 3  
		WHEN ''08'' THEN 4  
		WHEN ''09'' THEN 4  
		WHEN ''10'' THEN 4  
		WHEN ''12'' THEN 4  
		ELSE 5
		END,
	class_name NULLS LAST,
	supplies_name NULLS LAST', 2, '[{"preview": "テスト穿刺針", "can_calc": "0", "data_code": "supplies_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_name", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "supplies_base_date", "data_name": "データ基準日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "supplies_base_date", "disp_format": "yyyy/mm/dd", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ind_rst_value", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "ind_rst_value", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "total_unitH", "data_name": "各日医材合計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "total_unitH", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "total_unitV", "data_name": "医材計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "total_unitV", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [10, 11]}', '薬剤週間薬剤集計表　@patId @facilityCd  @fromdate  @todate', '2021-04-25 16:40:02', CURRENT_TIMESTAMP, '[]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (150, 'WITH 
Selunique AS (
	SELECT 
    pat_id,
	  ELEMENT->> ''period_start'' AS treat_date,
		ELEMENT ->> ''disp_order'' AS disp_order,
		ELEMENT ->> ''in_out'' AS in_out,
		ELEMENT ->> ''move_in_out'' AS move_in_out,
		ELEMENT ->> ''ctl_no'' AS ctl_no,
	CASE
			
			WHEN ELEMENT ->> ''move_in_out'' = ''4'' THEN
			''入院'' 
			WHEN ELEMENT ->> ''move_in_out'' = ''5'' THEN
			''外来''
			WHEN ELEMENT ->> ''move_in_out'' = ''6'' THEN
			''外来''

		END AS move_in_out_name 
	FROM
		pat_unique,
		jsonb_array_elements ( in_out_visit_history_info ) AS ELEMENT 
	WHERE
		pat_id in (@patIds)
		AND facility_cd = @facilityCd
	ORDER BY
		treat_date ASC,ctl_no desc 
	),
	SeluniqueDis AS (
	  SELECT
		  pat_id,
			treat_date,
      ROW_NUMBER() OVER (PARTITION BY pat_id, treat_date ORDER BY treat_date ASC,ctl_no desc) AS rm,  
			 move_in_out_name
			 FROM
			 Selunique
),
 DateRange AS (  
    SELECT 
			  pat_id,
        MIN(treat_date)::date AS start_date,  
        MAX(treat_date)::date AS end_date  
    FROM  
        SeluniqueDis 
		WHERE rm = 1
		AND move_in_out_name is not null
		GROUP BY pat_id

 ),
AllDates AS (  
     SELECT  
        pat_id,
        generate_series(start_date, end_date, ''1 day''::interval)::date AS treat_date  
    FROM  
        DateRange

),
FilledData AS (  
    SELECT
		  a.pat_id,
			a.treat_date,
      ROW_NUMBER() OVER (PARTITION BY a.pat_id, a.treat_date ORDER BY a.treat_date,ctl_no desc) AS rn,   
       y.move_in_out_name  
    FROM  
        AllDates a
    LEFT JOIN  
        Selunique y ON a.treat_date = y.treat_date::date AND a.pat_id = y.pat_id

),
  
RankedRecords AS ( 
SELECT  
*,
    to_char(treat_date, ''YYYYMMDD'') as reg_date,
		SUM(CASE WHEN move_in_out_name = ''入院'' THEN 1 ELSE 0 END) OVER (PARTITION BY pat_id ORDER BY treat_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS InpatientSequenceStart,  
    SUM(CASE WHEN move_in_out_name = ''外来'' THEN 1 ELSE 0 END) OVER (PARTITION BY pat_id ORDER BY treat_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ForeignerSequenceStart  
FROM  
    FilledData  
WHERE  
    rn = 1		
		)
		
SELECT  
    *  
FROM  
    RankedRecords', 2, '[{"preview": "0", "can_calc": "0", "data_code": "out_pat_cnt", "data_name": "外来合計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "out_pat_cnt", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '薬剤週間薬剤集計表　外来合計@facilityCd  @fromdate  @todate', '2021-05-07 10:00:02', CURRENT_TIMESTAMP, '[]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (151, 'WITH 
Selunique AS (
	SELECT 
    pat_id,
	  ELEMENT->> ''period_start'' AS treat_date,
		ELEMENT ->> ''disp_order'' AS disp_order,
		ELEMENT ->> ''in_out'' AS in_out,
		ELEMENT ->> ''move_in_out'' AS move_in_out,
		ELEMENT ->> ''ctl_no'' AS ctl_no,
	CASE
			
			WHEN ELEMENT ->> ''move_in_out'' = ''4'' THEN
			''入院'' 
			WHEN ELEMENT ->> ''move_in_out'' = ''5'' THEN
			''外来''
			WHEN ELEMENT ->> ''move_in_out'' = ''6'' THEN
			''外来''

		END AS move_in_out_name 
	FROM
		pat_unique,
		jsonb_array_elements ( in_out_visit_history_info ) AS ELEMENT 
	WHERE
		pat_id in (@patIds)
		AND facility_cd = @facilityCd
	ORDER BY
		treat_date ASC,ctl_no desc 
	),
	SeluniqueDis AS (
	  SELECT
		  pat_id,
			treat_date,
      ROW_NUMBER() OVER (PARTITION BY pat_id, treat_date ORDER BY treat_date ASC,ctl_no desc) AS rm,  
			 move_in_out_name
			 FROM
			 Selunique
),
 DateRange AS (  
    SELECT 
			  pat_id,
        MIN(treat_date)::date AS start_date,  
        MAX(treat_date)::date AS end_date  
    FROM  
        SeluniqueDis 
		WHERE rm = 1
		AND move_in_out_name is not null
		GROUP BY pat_id

 ),
AllDates AS (  
     SELECT  
        pat_id,
        generate_series(start_date, end_date, ''1 day''::interval)::date AS treat_date  
    FROM  
        DateRange

),
FilledData AS (  
    SELECT
		  a.pat_id,
			a.treat_date,
      ROW_NUMBER() OVER (PARTITION BY a.pat_id, a.treat_date ORDER BY a.treat_date,ctl_no desc) AS rn,   
       y.move_in_out_name  
    FROM  
        AllDates a
    LEFT JOIN  
        Selunique y ON a.treat_date = y.treat_date::date AND a.pat_id = y.pat_id

),
  
RankedRecords AS ( 
SELECT  
*,
    to_char(treat_date, ''YYYYMMDD'') as reg_date,
		SUM(CASE WHEN move_in_out_name = ''入院'' THEN 1 ELSE 0 END) OVER (PARTITION BY pat_id ORDER BY treat_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS InpatientSequenceStart,  
    SUM(CASE WHEN move_in_out_name = ''外来'' THEN 1 ELSE 0 END) OVER (PARTITION BY pat_id ORDER BY treat_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ForeignerSequenceStart  
FROM  
    FilledData  
WHERE  
    rn = 1		
		)
		
SELECT  
    *  
FROM  
    RankedRecords', 2, '[{"preview": "0", "can_calc": "0", "data_code": "hosp_pat_cnt", "data_name": "入院合計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "hosp_pat_cnt", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '薬剤週間薬剤集計表　入院合計@facilityCd  @fromdate  @todate', '2021-05-07 10:00:02', CURRENT_TIMESTAMP, '[]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (230, 'WITH mst_equi AS (
	SELECT
		equipment_cd,
		equipment_name
	FROM
		mst_equipment
	WHERE
		facility_cd = @facilityCd
),
mst_equic AS (
	SELECT
		class_cd,
		class_name
	FROM
		mst_equipment_class
	WHERE
		facility_cd = @facilityCd
),
mst_medi AS (
	SELECT
		medicine_cd,
		medicine_name
	FROM
		mst_medicine
	WHERE
		facility_cd = @facilityCd
),
mst_medic AS (
	SELECT
		class_cd,
		class_name
	FROM
		mst_medicine_class
	WHERE
		facility_cd = @facilityCd
),
mst_dial AS (
	SELECT
		dialyzer_cd,
		model_number
	FROM
		mst_dialyzer
	WHERE
		facility_cd = @facilityCd
)

SELECT
	supplies_cd,
	supplies_class,
	CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN supplies_cd
	END AS equipment_cd,
	CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'',''01'') THEN supplies_cd
	END AS medicine_cd,
	CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN equipment_name
		   WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN medicine_name
		   WHEN supplies_class IN (''01'') THEN model_number
	END AS supplies_name,
	CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd
		   ELSE ''-1''
	END AS class_cd,
	CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN mec.class_name
	     WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN mmc.class_name
	     WHEN supplies_class IN (''01'') THEN ''ダイアライザ''
			 END AS class_name,
	supplies_base_date,
	ind_rst_value
FROM
	ord_material_save oms
LEFT JOIN mst_equi me ON oms.supplies_cd::INTEGER = me.equipment_cd
LEFT JOIN mst_equic mec ON oms.class_cd::INTEGER = mec.class_cd
LEFT JOIN mst_medi mm ON oms.supplies_cd::INTEGER = mm.medicine_cd
LEFT JOIN mst_medic mmc ON oms.class_cd::INTEGER = mmc.class_cd
LEFT JOIN mst_dialyzer md ON oms.supplies_cd::INTEGER = md.dialyzer_cd
WHERE
	pat_id in (@patIds)
AND oms.facility_cd = @facilityCd
AND supplies_base_no in (@ordNos)
AND supplies_base_date::TIMESTAMP BETWEEN date_trunc(''day'', @fromDate ::timestamp) AND date_trunc(''day'', @toDate ::timestamp)
AND	ind_rst_class = ''1''
AND supplies_class <> ''16''
AND supplies_class <> ''23''
AND supplies_class <> ''24''
AND CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN
					 CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd::INTEGER IN (@eqIds)
					 ELSE -1 IN (@eqIds)
					 END
		     WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN
					 CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd::INTEGER IN (@medIds)
					 ELSE -1 IN (@medIds)
					 END
		     WHEN supplies_class IN (''01'') THEN supplies_cd::INTEGER IN (@diaIds)
	  END
ORDER BY
	CASE supplies_class
		WHEN ''01'' THEN 1  
		WHEN ''00'' THEN 2  
		WHEN ''02'' THEN 2  
		WHEN ''03'' THEN 2  
		WHEN ''04'' THEN 2  
		WHEN ''05'' THEN 2  
		WHEN ''06'' THEN 2  
		WHEN ''07'' THEN 2  
		WHEN ''11'' THEN 2   
		WHEN ''08'' THEN 3  
		WHEN ''09'' THEN 3  
		WHEN ''10'' THEN 3  
		WHEN ''12'' THEN 3  
		WHEN ''20'' THEN 3  
		WHEN ''21'' THEN 3  
		WHEN ''22'' THEN 3  
		ELSE 4
		END,
	class_name NULLS LAST,
	supplies_name NULLS LAST', 2, '[{"preview": "テスト穿刺針", "can_calc": "0", "data_code": "supplies_name", "data_name": "医療材料名(分解)", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_name", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "supplies_base_date", "data_name": "データ基準日(分解)", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "supplies_base_date", "disp_format": "yyyy/mm/dd", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ind_rst_value", "data_name": "数量(分解)", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "ind_rst_value", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [10, 11]}', '薬剤週間薬剤集計表　@patId @facilityCd  @fromdate  @todate', '2021-04-25 16:40:02', CURRENT_TIMESTAMP, '[]');
