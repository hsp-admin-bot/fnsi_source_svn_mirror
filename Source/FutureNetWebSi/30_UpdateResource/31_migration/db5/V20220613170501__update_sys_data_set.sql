DELETE from sys_data_set where sql_cd = -18;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-18, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1 
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, order_code AS (
SELECT--投与薬剤情報(通常)
    mmd.in_hospital_cd_1 AS e01,
    CASE WHEN ''0'' in (SELECT a1 FROM do_order_data_from) THEN json_idx ELSE NULL END AS login_ord,
    CASE WHEN ''1'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''class_cd'', ''999999999999'' ) ELSE NULL END AS class_cd,
    CASE WHEN ''2'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''medicine_type'', ''999999999999'' ) ELSE NULL END AS medicine_type,
    CASE WHEN ''3'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''cd'', ''999999999999'' ) ELSE NULL END AS medi_cd,
    CASE WHEN ''4'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''timing_cd'', ''999999999999'' ) ELSE NULL END AS timing_cd,
    CASE WHEN ''5'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' ) ELSE NULL END AS procedure_cd,
    CASE WHEN ''6'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''date_interval'', ''999999999999'' ) ELSE NULL END AS date_interval    
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'')
  WHERE ord.ord_no = @ordNo 
)
, data_all AS (
select  
''指示薬剤''::TEXT as detail_id,
        a.medi_cd1
        ,case when ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100)::TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100)::TEXT)
         end) 
         else (sum(medi_amount::Float)*100)::TEXT end  as  medi_amount
        ,1 as medi_back
        ,a.medi_unit        
        from 
        (select
      ''指示薬剤'' as detail_id,
        medc.in_hospital_cd_1 as medi_class_cd,
        medc.class_name as medi_class_type,
        mmd.medicine_name  as medi_name,
        case when medi ->> ''amount''  is null then ''0'' else 
        (case when char_length(split_part(medi ->> ''amount'' ,''.'', 2 ))>2 then ((split_part((((medi ->> ''amount'')::FLOAT)*100)::TEXT,''.'', 1 )::FLOAT)/100)::TEXT else medi ->> ''amount'' end)
 end  as medi_amount,
        mmd.unit as medi_unit,
      (case when mmd.unit_second is null then to_number(medi ->> ''amount'',''FM99999.99'') else (case  when mmd.is_exchange = ''0'' then to_number(medi ->> ''amount'',''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second   when mmd.is_exchange = ''1'' then trunc( to_number(medi ->> ''amount'',''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second + 0.9 ,0) when mmd.is_exchange = ''2'' then 1 else  to_number(medi ->> ''amount'',''FM99999.99'') end) end) as res_amount,
        mmd.unit_second as res_unit,
        medi ->> ''timing_name'' as medi_timing_name,
        mp.pricedure_name as procedure_name,
        mp.in_hospital_cd_a1 as procedure_cd1,
        mmd.in_hospital_cd_1 as medi_cd1,
        mmd.in_hospital_cd_2 as medi_cd2,
        mmd.in_hospital_cd_3 as medi_cd3,
        mmd.in_hospital_cd_4 as medi_cd4
    from
        mst_medicine_class as medc,
        ord_main as ord
    cross join lateral
        json_array_elements (ord.ind_medi_info :: json) medi
    left outer join
        mst_medicine as mmd
    on
        mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    left outer join
        mst_procedure as mp
    on
        mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    where
        mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and
    ord.ord_no =  @ordNo)  as a 
    GROUP BY a.medi_cd1,a.medi_unit 
)

SELECT 
    detail_id, medi_cd1, medi_amount, medi_back, medi_unit, login_ord, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
FROM        
    data_all
    LEFT JOIN order_code ON order_code.e01 = data_all.medi_cd1
ORDER BY
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END
limit 135', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示）投与薬剤コード', '2020-04-10 15:28:38.712', '2022-06-13 09:08:31.915', NULL);
