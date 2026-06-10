DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (261, 326);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (261, 'WITH pat_treat_patt AS (
  SELECT
    pat_id,
    ind_treatment_cd,
    ind_kur_cd,
    treat_week,
    CAST(info->>''cd'' AS INTEGER) AS cd,
    CAST(info->>''no'' AS INTEGER) AS no,
    CAST(info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(info->>''init_date'' AS TIMESTAMP) AS init_date,
    CAST(info->>''timing_cd'' AS INTEGER) AS timing_cd,
    CAST(info->>''amount'' AS DECIMAL) AS amount,
    CAST(info->>''procedure_cd'' AS INTEGER) AS procedure_cd,
		info->>''comment'' as comment,
		CAST(info->>''date_interval'' AS INTEGER) AS date_interval,
    CONCAT(info->>''ind_user_last_name'', info->>''ind_user_first_name'') as ind_user_name,
    CONCAT(info->>''upd_user_last_name'', info->>''upd_user_first_name'') as upd_user_name
  FROM
    pat_treatment_pattern,
    LATERAL jsonb_array_elements(ind_medi_info) AS info
  WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND CAST(info->>''init_date'' AS TIMESTAMP) <= @toDate
)
, pat_treat_patt_extEND AS (
	SELECT
		ptp.*,
		CASE
			WHEN medicine_type = ''2'' THEN mix.medicine_mix_name
			ELSE mm.medicine_name
		END AS medicine_name,
		CASE
			WHEN medicine_type = ''2'' THEN mix.class_cd
			ELSE mm.class_cd
		END AS class_cd,
		CASE
			WHEN medicine_type = ''2'' THEN
				CASE WHEN mix.class_cd = ''-1'' THEN ''未分類''
				ELSE mix_cls.class_name END
			ELSE
				CASE WHEN mm.class_cd = ''-1'' THEN ''未分類''
				ELSE med_cls.class_name END 
		END AS class_name,
		CASE
			WHEN medicine_type = ''2'' THEN mix_cls.class_type
			ELSE med_cls.class_type
		END AS class_type,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_1 ELSE mix.in_hospital_cd_1 END AS medi_in_hospital_cd_1,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_2 ELSE mix.in_hospital_cd_2 END AS medi_in_hospital_cd_2,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_3 ELSE mix.in_hospital_cd_3 END AS medi_in_hospital_cd_3,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_4 ELSE '''' END AS medi_in_hospital_cd_4,
		CASE
			WHEN medicine_type = ''2'' THEN mix.unit
			ELSE mm.unit
		END AS unit,
    mp.pricedure_name,
    mp.in_hosp_a_startdate,
    mp.in_hospital_cd_a1,
    mp.in_hospital_cd_a2,
    mp.in_hosp_b_startdate,
    mp.in_hospital_cd_b1,
    mp.in_hospital_cd_b2,
    mmt.medicate_timing_name,
    CASE
      WHEN is_exchange IS NOT NULL THEN
        CASE
          WHEN is_exchange = ''0'' THEN
            CASE
              WHEN unit_converted_amount IS NOT NULL 
                AND unit_converted_amount <> 0
                AND unit_converted_amount_second IS NOT NULL
                AND unit_converted_amount_second <> 0
              THEN ROUND(ptp.amount / unit_converted_amount * unit_converted_amount_second, unit_decimal_point_second)
              ELSE ROUND(0, unit_decimal_point_second)
            END

          WHEN is_exchange = ''1'' THEN
            CASE
              WHEN unit_converted_amount IS NOT NULL 
                AND unit_converted_amount <> 0
                AND unit_converted_amount_second IS NOT NULL
                AND unit_converted_amount_second <> 0
              THEN ROUND(CEIL(ptp.amount / unit_converted_amount) * unit_converted_amount_second, unit_decimal_point_second)
              ELSE ROUND(0, unit_decimal_point_second)
            END

          WHEN is_exchange = ''2'' THEN
            CASE
              WHEN unit_converted_amount_second IS NOT NULL
              THEN unit_converted_amount_second
              ELSE ROUND(0, unit_decimal_point_second)
            END
          ELSE ROUND(0, unit_decimal_point_second)
        END
        
      ELSE NULL
    END AS receipt_value,
    mm.unit_second
  FROM
    pat_treat_patt ptp
    LEFT JOIN mst_medicine mm
           ON mm.medicine_cd = ptp.cd
          AND ptp.medicine_type = 1
    LEFT JOIN mst_medicine_mix mix
           ON mix.medicine_mix_cd = ptp.cd
          AND ptp.medicine_type = 2
    LEFT JOIN mst_medicine_class med_cls 
           ON mm.class_cd = med_cls.class_cd
    LEFT JOIN mst_medicine_class mix_cls 
           ON mix.class_cd = mix_cls.class_cd
    LEFT JOIN mst_procedure mp
           ON mp.procedure_cd = ptp.procedure_cd
    LEFT JOIN mst_medicate_timing mmt
           ON mmt.medicate_timing_cd = ptp.timing_cd
)
, med_sort AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
)
, med_mix_sort AS (
	SELECT
		index_no AS code_mix_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
)
, med_class_sort AS (
	SELECT
		index_no AS class_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
)
, med_timing_sort AS (
	SELECT
		index_no AS timing_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicate_timing''
)
, proc_sort AS (
	SELECT
		index_no AS proc_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_procedure''
)
, ord_mai AS (
	SELECT
		ord_no,
		pat_id,
		om.treat_date,
		ind_treatment_cd,
		ind_kur_cd,
		treat_week,
		CAST(info->>''cd'' AS INTEGER) AS cd,
		CAST(info->>''no'' AS INTEGER) AS no,
    json_idx
	FROM
    ord_main om
		CROSS JOIN LATERAL jsonb_array_elements(ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
	WHERE
		 ord_no IN ( @ordNos )
	ORDER BY
		treat_date
)
, sort_fields AS (
  SELECT elem, ord
  FROM mst_facility_setting mfs,
       jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''json_idx''),
      (''1'', ''class_cd''),
      (''2'', ''medicine_type''),
      (''3'', ''cd''),
      (''4'', ''timing_cd''),
      (''5'', ''procedure_cd''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)
, pat_treat_patt_last AS (
SELECT
	om.json_idx,
	mcs.class_order,
  ptpe.medicine_type,
	ms.code_order,
	mms.code_mix_order,
	mts.timing_order,
	p.proc_order,
	ptpe.date_interval,
  om.ord_no,
  ptpe.pat_id,
  ptpe.ind_treatment_cd,
  ptpe.ind_kur_cd,
  ptpe.treat_week,
  ptpe.cd,
  ptpe.class_cd,
  ptpe.class_type,
  om.treat_date,
  ptpe.init_date,
  ptpe.medicine_name,    
  ptpe.class_name,  
  ptpe.medi_in_hospital_cd_1,
  ptpe.medi_in_hospital_cd_2,
  ptpe.medi_in_hospital_cd_3,
  ptpe.medi_in_hospital_cd_4,  
  ptpe.amount,
  ptpe.unit,
  ptpe.receipt_value,
  ptpe.unit_second,
  ptpe.procedure_cd,
  ptpe.pricedure_name,
  ptpe.timing_cd,
  CASE 
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP AND om.treat_date :: TIMESTAMP < date_trunc(''day'', ptpe.in_hosp_b_startdate) THEN ptpe.in_hospital_cd_a1
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP AND om.treat_date :: TIMESTAMP < date_trunc(''day'', ptpe.in_hosp_a_startdate) THEN ptpe.in_hospital_cd_b1
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP AND date_trunc(''day'', ptpe.in_hosp_b_startdate) IS NULL THEN ptpe.in_hospital_cd_a1
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP AND date_trunc(''day'', ptpe.in_hosp_a_startdate) IS NULL THEN ptpe.in_hospital_cd_b1
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) < date_trunc(''day'', ptpe.in_hosp_a_startdate) AND date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP THEN ptpe.in_hospital_cd_a1
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) < date_trunc(''day'', ptpe.in_hosp_b_startdate) AND date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP THEN ptpe.in_hospital_cd_b1
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) = date_trunc(''day'', ptpe.in_hosp_b_startdate) AND (om.treat_date :: TIMESTAMP) >= date_trunc(''day'', ptpe.in_hosp_a_startdate) THEN ptpe.in_hospital_cd_a1
    ELSE ''''
  END AS procedure_in_hospital_cd_1,
  CASE 
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP AND om.treat_date :: TIMESTAMP < date_trunc(''day'', ptpe.in_hosp_b_startdate) THEN ptpe.in_hospital_cd_a2
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP AND om.treat_date :: TIMESTAMP < date_trunc(''day'', ptpe.in_hosp_a_startdate) THEN ptpe.in_hospital_cd_b2
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP AND date_trunc(''day'', ptpe.in_hosp_b_startdate) IS NULL THEN ptpe.in_hospital_cd_a2
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP AND date_trunc(''day'', ptpe.in_hosp_a_startdate) IS NULL THEN ptpe.in_hospital_cd_b2
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) < date_trunc(''day'', ptpe.in_hosp_a_startdate) AND date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP THEN ptpe.in_hospital_cd_a2
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) < date_trunc(''day'', ptpe.in_hosp_b_startdate) AND date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP THEN ptpe.in_hospital_cd_b2
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) = date_trunc(''day'', ptpe.in_hosp_b_startdate) AND (om.treat_date :: TIMESTAMP) >= date_trunc(''day'', ptpe.in_hosp_a_startdate) THEN ptpe.in_hospital_cd_a2
    ELSE ''''
  END AS procedure_in_hospital_cd_2,
  ptpe.medicate_timing_name,
  ptpe.comment,
  ptpe.ind_user_name,
  ptpe.upd_user_name
FROM
  ord_mai om
	INNER JOIN pat_treat_patt_extEND ptpe
					ON ptpe.ind_treatment_cd = om.ind_treatment_cd
				 AND ptpe.treat_week = om.treat_week
				 AND ptpe.pat_id = om.pat_id
				 AND ptpe.init_date <= CAST(om.treat_date AS TIMESTAMP)
				 AND ptpe.cd = om.cd
				 AND ptpe.no = om.no
	LEFT JOIN med_sort ms ON ms.code = ptpe.cd AND ptpe.medicine_type = 1
	LEFT JOIN med_mix_sort mms ON mms.code = ptpe.cd AND ptpe.medicine_type = 2
	LEFT JOIN med_class_sort mcs ON mcs.code = ptpe.class_cd
	LEFT JOIN med_timing_sort mts ON mts.code = ptpe.timing_cd
	LEFT JOIN proc_sort p ON p.code = ptpe.procedure_cd	
)

SELECT *
FROM pat_treat_patt_last ptpl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''json_idx''      THEN ARRAY[ptpl.json_idx,        NULL]
      WHEN ''class_cd''      THEN ARRAY[ptpl.class_order,     NULL]
      WHEN ''medicine_type'' THEN ARRAY[ptpl.medicine_type,   NULL]
      WHEN ''cd''            THEN ARRAY[ptpl.code_order,      ptpl.code_mix_order]
      WHEN ''timing_cd''     THEN ARRAY[ptpl.timing_order,    NULL]
      WHEN ''procedure_cd''  THEN ARRAY[ptpl.proc_order,      NULL]
      WHEN ''date_interval'' THEN ARRAY[ptpl.date_interval,   NULL]
    END
    ORDER BY ord
  )
  FROM priority
)', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未分類", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬(定期)", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(定期)", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(定期)", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(定期)", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬(定期)", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬(定期)", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10]}', '指示：投薬(定期) 単型 @patId @ordNos @facilityCd使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (326, 'WITH pat_treat_patt AS (
  SELECT
    pat_id,
    ind_treatment_cd,
    ind_kur_cd,
    treat_week,
    CAST(info->>''cd'' AS INTEGER) AS cd,
    CAST(info->>''no'' AS INTEGER) AS no,
    CAST(info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(info->>''init_date'' AS TIMESTAMP) AS init_date,
    CAST(info->>''timing_cd'' AS INTEGER) AS timing_cd,
    CAST(info->>''amount'' AS DECIMAL) AS amount,
    CAST(info->>''procedure_cd'' AS INTEGER) AS procedure_cd,
		info->>''comment'' as comment,
		CAST(info->>''date_interval'' AS INTEGER) AS date_interval,
    CONCAT(info->>''ind_user_last_name'', info->>''ind_user_first_name'') as ind_user_name,
    CONCAT(info->>''upd_user_last_name'', info->>''upd_user_first_name'') as upd_user_name
  FROM
    pat_treatment_pattern,
    LATERAL jsonb_array_elements(ind_medi_info) AS info
  WHERE
    pat_id IN ( @patIds )
    AND facility_cd = @facilityCd
    AND CAST(info->>''init_date'' AS TIMESTAMP) <= @toDate
)
, pat_treat_patt_extEND AS (
	SELECT
		ptp.*,
		CASE
			WHEN medicine_type = ''2'' THEN mix.medicine_mix_name
			ELSE mm.medicine_name
		END AS medicine_name,
		CASE
			WHEN medicine_type = ''2'' THEN mix.class_cd
			ELSE mm.class_cd
		END AS class_cd,
		CASE
			WHEN medicine_type = ''2'' THEN
				CASE WHEN mix.class_cd = ''-1'' THEN ''未分類''
				ELSE mix_cls.class_name END
			ELSE
				CASE WHEN mm.class_cd = ''-1'' THEN ''未分類''
				ELSE med_cls.class_name END 
		END AS class_name,
		CASE
			WHEN medicine_type = ''2'' THEN mix_cls.class_type
			ELSE med_cls.class_type
		END AS class_type,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_1 ELSE mix.in_hospital_cd_1 END AS medi_in_hospital_cd_1,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_2 ELSE mix.in_hospital_cd_2 END AS medi_in_hospital_cd_2,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_3 ELSE mix.in_hospital_cd_3 END AS medi_in_hospital_cd_3,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_4 ELSE '''' END AS medi_in_hospital_cd_4,
		CASE
			WHEN medicine_type = ''2'' THEN mix.unit
			ELSE mm.unit
		END AS unit,
    mp.pricedure_name,
    mp.in_hosp_a_startdate,
    mp.in_hospital_cd_a1,
    mp.in_hospital_cd_a2,
    mp.in_hosp_b_startdate,
    mp.in_hospital_cd_b1,
    mp.in_hospital_cd_b2,
    mmt.medicate_timing_name,
    CASE
      WHEN is_exchange IS NOT NULL THEN
        CASE
          WHEN is_exchange = ''0'' THEN
            CASE
              WHEN unit_converted_amount IS NOT NULL 
                AND unit_converted_amount <> 0
                AND unit_converted_amount_second IS NOT NULL
                AND unit_converted_amount_second <> 0
              THEN ROUND(ptp.amount / unit_converted_amount * unit_converted_amount_second, unit_decimal_point_second)
              ELSE ROUND(0, unit_decimal_point_second)
            END

          WHEN is_exchange = ''1'' THEN
            CASE
              WHEN unit_converted_amount IS NOT NULL 
                AND unit_converted_amount <> 0
                AND unit_converted_amount_second IS NOT NULL
                AND unit_converted_amount_second <> 0
              THEN ROUND(CEIL(ptp.amount / unit_converted_amount) * unit_converted_amount_second, unit_decimal_point_second)
              ELSE ROUND(0, unit_decimal_point_second)
            END

          WHEN is_exchange = ''2'' THEN
            CASE
              WHEN unit_converted_amount_second IS NOT NULL
              THEN unit_converted_amount_second
              ELSE ROUND(0, unit_decimal_point_second)
            END
          ELSE ROUND(0, unit_decimal_point_second)
        END
        
      ELSE NULL
    END AS receipt_value,
    mm.unit_second
  FROM
    pat_treat_patt ptp
    LEFT JOIN mst_medicine mm
           ON mm.medicine_cd = ptp.cd
          AND ptp.medicine_type = 1
    LEFT JOIN mst_medicine_mix mix
           ON mix.medicine_mix_cd = ptp.cd
          AND ptp.medicine_type = 2
    LEFT JOIN mst_medicine_class med_cls 
           ON mm.class_cd = med_cls.class_cd
    LEFT JOIN mst_medicine_class mix_cls 
           ON mix.class_cd = mix_cls.class_cd
    LEFT JOIN mst_procedure mp
           ON mp.procedure_cd = ptp.procedure_cd
    LEFT JOIN mst_medicate_timing mmt
           ON mmt.medicate_timing_cd = ptp.timing_cd
)
, med_sort AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
)
, med_mix_sort AS (
	SELECT
		index_no AS code_mix_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
)
, med_class_sort AS (
	SELECT
		index_no AS class_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
)
, med_timing_sort AS (
	SELECT
		index_no AS timing_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicate_timing''
)
, proc_sort AS (
	SELECT
		index_no AS proc_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_procedure''
)
, ord_mai AS (
	SELECT
		ord_no,
		pat_id,
		om.treat_date,
		ind_treatment_cd,
		ind_kur_cd,
		treat_week,
		CAST(info->>''cd'' AS INTEGER) AS cd,
		CAST(info->>''no'' AS INTEGER) AS no,
    json_idx
	FROM
    ord_main om
		CROSS JOIN LATERAL jsonb_array_elements(ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
	WHERE
		 ord_no IN ( @ordNos )
	ORDER BY
		treat_date
)
, sort_fields AS (
  SELECT elem, ord
  FROM mst_facility_setting mfs,
       jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''json_idx''),
      (''1'', ''class_cd''),
      (''2'', ''medicine_type''),
      (''3'', ''cd''),
      (''4'', ''timing_cd''),
      (''5'', ''procedure_cd''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)
, pat_treat_patt_last AS (
SELECT
	om.json_idx,
	mcs.class_order,
  ptpe.medicine_type,
	ms.code_order,
	mms.code_mix_order,
	mts.timing_order,
	p.proc_order,
	ptpe.date_interval,
  om.ord_no,
  ptpe.pat_id,
  ptpe.ind_treatment_cd,
  ptpe.ind_kur_cd,
  ptpe.treat_week,
  ptpe.cd,
  ptpe.class_cd,
  ptpe.class_type,
  om.treat_date,
  ptpe.init_date,
  ptpe.medicine_name,    
  ptpe.class_name,  
  ptpe.medi_in_hospital_cd_1,
  ptpe.medi_in_hospital_cd_2,
  ptpe.medi_in_hospital_cd_3,
  ptpe.medi_in_hospital_cd_4,  
  ptpe.amount,
  ptpe.unit,
  ptpe.receipt_value,
  ptpe.unit_second,
  ptpe.procedure_cd,
  ptpe.pricedure_name,
  ptpe.timing_cd,
  CASE 
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP AND om.treat_date :: TIMESTAMP < date_trunc(''day'', ptpe.in_hosp_b_startdate) THEN ptpe.in_hospital_cd_a1
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP AND om.treat_date :: TIMESTAMP < date_trunc(''day'', ptpe.in_hosp_a_startdate) THEN ptpe.in_hospital_cd_b1
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP AND date_trunc(''day'', ptpe.in_hosp_b_startdate) IS NULL THEN ptpe.in_hospital_cd_a1
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP AND date_trunc(''day'', ptpe.in_hosp_a_startdate) IS NULL THEN ptpe.in_hospital_cd_b1
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) < date_trunc(''day'', ptpe.in_hosp_a_startdate) AND date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP THEN ptpe.in_hospital_cd_a1
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) < date_trunc(''day'', ptpe.in_hosp_b_startdate) AND date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP THEN ptpe.in_hospital_cd_b1
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) = date_trunc(''day'', ptpe.in_hosp_b_startdate) AND (om.treat_date :: TIMESTAMP) >= date_trunc(''day'', ptpe.in_hosp_a_startdate) THEN ptpe.in_hospital_cd_a1
    ELSE ''''
  END AS procedure_in_hospital_cd_1,
  CASE 
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP AND om.treat_date :: TIMESTAMP < date_trunc(''day'', ptpe.in_hosp_b_startdate) THEN ptpe.in_hospital_cd_a2
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP AND om.treat_date :: TIMESTAMP < date_trunc(''day'', ptpe.in_hosp_a_startdate) THEN ptpe.in_hospital_cd_b2
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP AND date_trunc(''day'', ptpe.in_hosp_b_startdate) IS NULL THEN ptpe.in_hospital_cd_a2
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP AND date_trunc(''day'', ptpe.in_hosp_a_startdate) IS NULL THEN ptpe.in_hospital_cd_b2
    WHEN date_trunc(''day'', ptpe.in_hosp_b_startdate) < date_trunc(''day'', ptpe.in_hosp_a_startdate) AND date_trunc(''day'', ptpe.in_hosp_a_startdate) <= om.treat_date :: TIMESTAMP THEN ptpe.in_hospital_cd_a2
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) < date_trunc(''day'', ptpe.in_hosp_b_startdate) AND date_trunc(''day'', ptpe.in_hosp_b_startdate) <= om.treat_date :: TIMESTAMP THEN ptpe.in_hospital_cd_b2
    WHEN date_trunc(''day'', ptpe.in_hosp_a_startdate) = date_trunc(''day'', ptpe.in_hosp_b_startdate) AND (om.treat_date :: TIMESTAMP) >= date_trunc(''day'', ptpe.in_hosp_a_startdate) THEN ptpe.in_hospital_cd_a2
    ELSE ''''
  END AS procedure_in_hospital_cd_2,
  ptpe.medicate_timing_name,
  ptpe.comment,
  ptpe.ind_user_name,
  ptpe.upd_user_name
FROM
  ord_mai om
	INNER JOIN pat_treat_patt_extEND ptpe
					ON ptpe.ind_treatment_cd = om.ind_treatment_cd
				 AND ptpe.treat_week = om.treat_week
				 AND ptpe.pat_id = om.pat_id
				 AND ptpe.init_date <= CAST(om.treat_date AS TIMESTAMP)
				 AND ptpe.cd = om.cd
				 AND ptpe.no = om.no
	LEFT JOIN med_sort ms ON ms.code = ptpe.cd AND ptpe.medicine_type = 1
	LEFT JOIN med_mix_sort mms ON mms.code = ptpe.cd AND ptpe.medicine_type = 2
	LEFT JOIN med_class_sort mcs ON mcs.code = ptpe.class_cd
	LEFT JOIN med_timing_sort mts ON mts.code = ptpe.timing_cd
	LEFT JOIN proc_sort p ON p.code = ptpe.procedure_cd	
)

SELECT *
FROM pat_treat_patt_last ptpl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''json_idx''      THEN ARRAY[ptpl.json_idx,        NULL]
      WHEN ''class_cd''      THEN ARRAY[ptpl.class_order,     NULL]
      WHEN ''medicine_type'' THEN ARRAY[ptpl.medicine_type,   NULL]
      WHEN ''cd''            THEN ARRAY[ptpl.code_order,      ptpl.code_mix_order]
      WHEN ''timing_cd''     THEN ARRAY[ptpl.timing_order,    NULL]
      WHEN ''procedure_cd''  THEN ARRAY[ptpl.proc_order,      NULL]
      WHEN ''date_interval'' THEN ARRAY[ptpl.date_interval,   NULL]
    END
    ORDER BY ord
  )
  FROM priority
)', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未分類", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬(定期)", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(定期)", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(定期)", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(定期)", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬(定期)", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬(定期)", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '指示：投薬(定期) 複数型 @patIds @ordNos @facilityCd使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
