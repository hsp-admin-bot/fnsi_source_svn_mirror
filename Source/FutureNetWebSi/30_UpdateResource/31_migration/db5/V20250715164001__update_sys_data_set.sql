DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-500069, 8109);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500069, 'WITH ssi_in_hospital_cd AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_ORDER_RECV''
    AND info->>''key2'' = ''IN_HOSPITAL_CD''
) 
, class_cd_ini AS (
  SELECT
    COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_CLASS_NAME''
    AND info->>''key2'' = (''MEDICATION_''|| @indMediInfo.no) -- 薬剤''
) 
, class_cd_info AS (
  SELECT
    class_cd AS class_cd
  FROM mst_medicine_class
  WHERE 
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND class_name = (SELECT VALUE FROM class_cd_ini)
  LIMIT 1
)
, is_new AS (
  SELECT 
    CASE 
        WHEN (@indMediInfo.cd='''') 
        THEN 0 
        ELSE 1 
    END AS is_new
)
INSERT INTO mst_medicine( 
      facility_cd
  ,   fn_medicine_cd
  ,   standard_medicine_cd
  ,   is_trial
  ,   medicine_name
  ,   medicine_short_name
  ,   unit
  ,   unit_second
  ,   class_cd
  ,   is_shot
  ,   use_start_date
  ,   use_end_date
  ,   is_medicated
  ,   unit_converted_amount
  ,   unit_converted_amount_second
  ,   anticoagulant_original_quantity
  ,   after_anticoagulant_quantity
  ,   in_hospital_cd_1
  ,   in_hospital_cd_2
  ,   in_hospital_cd_3
  ,   is_disp
  ,   is_del
  ,   reg_date
  ,   up_date
  ,   is_exchange
  ,   medicate_timing_cd
  ,   procedure_cd
  ,   unit_decimal_point
  ,   unit_decimal_point_second
  ,   in_hospital_cd_4
) 
SELECT
      @facilityCd
  ,   NULL
  ,   NULL
  ,   ''0''
  ,   @indMediInfo.name
  ,   NULL
  ,   @indMediInfo.unit
  ,   NULL
  ,   (SELECT COALESCE((SELECT class_cd FROM class_cd_info), -1))
  ,   ''0''
  ,   NULL
  ,   NULL
  ,   ''0''
  ,   ''0''
  ,   ''0''
  ,   ''0''
  ,   ''0''
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN @indMediInfo.cd
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indMediInfo.cd
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN @indMediInfo.cd
        WHEN ''4'' THEN NULL
      END
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
  ,   ''0''
  ,   NULL
  ,   NULL
  ,   ''0''
  ,   ''0''
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN @indMediInfo.cd
      END
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの薬剤(INSERT)', '2025-05-27 13:22:13.745', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(8109, 'WITH ssi_in_hospital_cd AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = ''@key0''
    AND info->>''key1'' = ''SSI_ORDER_RECV''
    AND info->>''key2'' = ''IN_HOSPITAL_CD''
),
procedure as (
  select procedure_cd
  from mst_procedure
  where is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
			WHEN ''1'' THEN in_hospital_cd_a1 = ''@indMediInfo.procedureCd''
			WHEN ''2'' THEN in_hospital_cd_a2 = ''@indMediInfo.procedureCd''
		END
	and facility_cd = ''@facilityCd''
	and ''@indMediInfo.procedureCd''<>''''
  limit 1
),
medicine as (
  SELECT mst_medicine.medicine_cd
      ,  mst_medicine.class_cd
      ,  COALESCE(mst_medicine_class.class_name,'''') AS class_name
      ,  COALESCE(mst_medicine.medicine_short_name,'''') AS medicine_short_name
  FROM mst_medicine
  LEFT JOIN mst_medicine_class ON mst_medicine.class_cd = mst_medicine_class.class_cd
  WHERE mst_medicine.is_del = ''0''
  and mst_medicine.is_disp = ''1''
  and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN mst_medicine.in_hospital_cd_1 = ''@indMediInfo.cd''
        WHEN ''2'' THEN mst_medicine.in_hospital_cd_2 = ''@indMediInfo.cd''
        WHEN ''3'' THEN mst_medicine.in_hospital_cd_3 = ''@indMediInfo.cd''
        WHEN ''4'' THEN mst_medicine.in_hospital_cd_4 = ''@indMediInfo.cd''
      END
  and mst_medicine.facility_cd = ''@facilityCd''
  and ''@indMediInfo.cd''<>''''
  limit 1
),
filteredValue as (
  SELECT jsonb_agg(value) AS filtered_ind_medi_info
  FROM (
      SELECT value
      FROM ord_main, jsonb_array_elements(ind_medi_info) WITH ORDINALITY arr(value, index)
      where ord_no = @ordNo  
      ORDER BY index
  ) filtered
),
isExistsData as (
  SELECT jsonb_agg(value) AS filtered_rst_medi_info
  FROM (
      SELECT value
      FROM ord_main, jsonb_array_elements(rst_medi_info) WITH ORDINALITY arr(value, index)
      where value ->> ''cd'' = (SELECT medicine_cd FROM medicine)::text
      and value ->> ''effect_flg'' = ''1''
      and ord_no = @ordNo  
      ORDER BY index
  ) filtered
),
newNo as (
  SELECT COALESCE(max(medi_info_no),-1) AS no
  FROM medicine_latest_no
  WHERE facility_cd = ''@facilityCd''
  and pat_id = @patId
)
UPDATE ord_main 
SET
  ind_medi_info = CASE WHEN (SELECT (SELECT filtered_rst_medi_info FROM isExistsData) is not null and (ind_medi_info <> ''[]'')) THEN ''@indMediInfoValue'' 
    ELSE 
      CASE WHEN (SELECT (SELECT filtered_ind_medi_info FROM filteredValue) is null) THEN 
        concat(''[{"cd":'',COALESCE((SELECT medicine_cd FROM medicine)::text,''null''),'',
        "no":'',(SELECT no+1 FROM newNo)::text,'',
        "name":"@indMediInfo.name",
        "unit":"@indMediInfo.unit",
        "amount":"@indMediInfo.amount",
        "comment":null,
        "class_cd":'',COALESCE((SELECT class_cd FROM medicine)::text,''null''),'',
        "init_date":"@indMediInfo.initDate",
        "timing_cd":null,
        "class_name":"'',COALESCE((SELECT class_name FROM medicine)::text,''''),''",
        "class_type": 0,
        "short_name":"'',COALESCE((SELECT medicine_short_name FROM medicine)::text,''''),''",
        "ind_user_id":@indMediInfo.updUserId,
        "input_class":@indMediInfo.inputClass,
        "is_editable":"@indMediInfo.isEditable",
        "upd_user_id":@indMediInfo.updUserId,
        "cop_order_no":null,
        "procedure_cd":'',COALESCE((SELECT procedure_cd FROM procedure)::text,''null''),'',
        "procedure_name": "@indMediInfo.procedureName",
        "date_interval":0,
        "medicine_type":@indMediInfo.medicineType,
        "ind_user_last_name":"@indMediInfo.indUserLastName",
        "upd_user_last_name":"@indMediInfo.updUserLastName",
        "ind_user_first_name":"@indMediInfo.indUserFirstName",
        "upd_user_first_name":"@indMediInfo.updUserFirstName"}]'')::jsonb 
      ELSE 
        (SELECT filtered_ind_medi_info::text FROM filteredValue)::jsonb  || concat(''[{"cd":'',(SELECT medicine_cd FROM medicine)::text,'',
        "no":'',(SELECT no+1 FROM newNo)::text,'',
        "name":"@indMediInfo.name",
        "unit":"@indMediInfo.unit",
        "amount":"@indMediInfo.amount",
        "comment":null,
        "class_cd":'',COALESCE((SELECT class_cd FROM medicine)::text,''null''),'',
        "init_date":"@indMediInfo.initDate",
        "timing_cd":null,
        "class_name":"'',COALESCE((SELECT class_name FROM medicine)::text,''''),''",
        "class_type": 0,
        "short_name":"'',COALESCE((SELECT medicine_short_name FROM medicine)::text,''''),''",
        "ind_user_id":@indMediInfo.updUserId,
        "input_class":@indMediInfo.inputClass,
        "is_editable":"@indMediInfo.isEditable",
        "upd_user_id":@indMediInfo.updUserId,
        "cop_order_no":null,
        "procedure_cd":'',COALESCE((SELECT procedure_cd FROM procedure)::text,''null''),'',
        "procedure_name": "@indMediInfo.procedureName",
        "date_interval":0,
        "medicine_type":@indMediInfo.medicineType,
        "ind_user_last_name":"@indMediInfo.indUserLastName",
        "upd_user_last_name":"@indMediInfo.updUserLastName",
        "ind_user_first_name":"@indMediInfo.indUserFirstName",
        "upd_user_first_name":"@indMediInfo.updUserFirstName"}]'')::jsonb 
      END 
    END 
WHERE
  ord_no = @ordNo
AND
  (SELECT medicine_cd FROM medicine) is not null', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(処方情報の更新)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": -500067}, {"sql_cd": -500031, "field_name": "user_id", "replace_var": "@indMediInfo.updUserId"}, {"sql_cd": -500031, "field_name": "user_last_name", "replace_var": "@indMediInfo.indUserLastName"}, {"sql_cd": -500031, "field_name": "user_first_name", "replace_var": "@indMediInfo.indUserFirstName"}, {"sql_cd": -500031, "field_name": "user_last_name", "replace_var": "@indMediInfo.updUserLastName"}, {"sql_cd": -500031, "field_name": "user_first_name", "replace_var": "@indMediInfo.updUserFirstName"}]'::jsonb);