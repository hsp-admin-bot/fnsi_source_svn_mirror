DELETE FROM ntss.sys_data_set WHERE sql_cd IN (-18,-181);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-181, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, do_mstmedi_cd AS (
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code, order_cd ->> ''name'' AS medi_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine'' 
)
, do_mstmedi_class_cd AS (
SELECT index_no AS medi_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code, order_cd ->> ''name'' AS medi_class_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine_class'' 
)
, do_mst_timing AS (
SELECT index_no AS timing_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code, order_cd ->> ''name'' AS timing_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicate_timing'' 
)
, do_mst_procedure AS (
SELECT index_no AS procedure_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code, order_cd ->> ''name'' AS procedure_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_procedure'' 
)
, do_medicine_mix_cd AS (
SELECT index_no AS medi_mix_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_mix_code, order_cd ->> ''name'' AS medi_mix_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine_mix'' 
)
, do_ord AS (
SELECT * FROM ord_main_restore as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
ORDER BY del_date DESC LIMIT 1
)
, do_medicine_mix_1 AS (
  SELECT
      TRIM(mmd.in_hospital_cd_1) AS item_cd,
      json_idx AS login_ord,
      TO_NUMBER( medi ->> ''class_cd'' :: text, ''999999999999'' ) AS class_M_cd,
      TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'' ) AS mix_M_cd,
      TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
      TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
      TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS medicine_mix_cd,
      TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
      TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
      TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
  FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
            LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
            LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(medi ->> ''class_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements (mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
  WHERE
      medi ->> ''medicine_type'' = ''2'' 
  AND ord.ord_no = @ordNo
UNION
    SELECT
      TRIM(mmd.in_hospital_cd_1) AS item_cd,
      json_idx AS login_ord,
      TO_NUMBER( medi ->> ''class_cd'' :: text, ''999999999999'' ) AS class_M_cd,
      TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'' ) AS mix_M_cd,
      TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
      TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
      TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS medicine_mix_cd,
      TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
      TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
      TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
  FROM
      do_ord AS ord
      CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
            LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
            LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(medi ->> ''class_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements (mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
  WHERE
      medi ->> ''medicine_type'' = ''2'' 
    AND ''0'' =(select count(*) from ord_main where ord_no = @ordNo)
)
, do_medicine_mix_2 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT item_cd, login_ord, medi_class_M_cd, medicine_type, medicine_mix_cd, timing_cd, procedure_cd, date_interval, class_M_cd, mix_M_cd 
   FROM do_medicine_mix_1
     ORDER BY 
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END) AS order_data
)
, do_medicine_mix_dis AS (
   SELECT 
      TRIM(item_cd) AS item_cd_m_dis,
      MIN(no2) AS ord_mk_dis
   FROM
      do_medicine_mix_2
   GROUP BY item_cd_m_dis
     ORDER BY ord_mk_dis
)
, do_medicine_mix AS (
   SELECT 
      no2 AS ord_mk, item_cd AS item_cd_m, login_ord AS login_ord_m, medi_class_M_cd, medicine_type AS medicine_type_m, medicine_mix_cd, timing_cd AS timing_cd_m, procedure_cd AS procedure_cd_m, date_interval AS date_interval_m, class_M_cd, mix_M_cd
   FROM
      do_medicine_mix_dis LEFT JOIN do_medicine_mix_2 ON item_cd_m_dis = item_cd AND ord_mk_dis = no2
   
)
, data_middle_all AS (
SELECT 
        ''指示薬剤del''::TEXT as detail_id,
    count_all.medi_cd1,
        SUM(count_all.medi_amount :: Float) AS  medi_amount,
        (SELECT count(count_all1.medi_cd1) FROM (SELECT  --ord_mainデータが存在場合
''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1        
     FROM 
        (select
      ''指示薬剤1'' as detail_id,
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
        left join 
                mst_medicine_class as medc 
        on 
                mmd.class_cd = medc.class_cd
    where
        --mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'' and
    ord.ord_no =  @ordNo)  as a 
        
UNION ALL
    SELECT --ord_mainデータが存在場合
        ''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1   
    FROM 
        (select
      ''指示薬剤1'' as detail_id,
        mmd.medicine_name  as medi_name,
                to_number(mmxd ->> ''amount'', ''99999.99'') as counts,
        to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) as medi_amount,
        mmd.unit as medi_unit,
        mp.pricedure_name as procedure_name,
        mp.in_hospital_cd_a1 as procedure_cd1,
        mmd.in_hospital_cd_1 as medi_cd1,
        mmd.in_hospital_cd_2 as medi_cd2,
        mmd.in_hospital_cd_3 as medi_cd3,
        mmd.in_hospital_cd_4 as medi_cd4
    from
        ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    where
        --mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'' and
    ord.ord_no =  @ordNo)  as a 
        
union all( --ord_mainデータが存在しない場合
    select  
''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1  
    from 
        (select
      ''指示薬剤1'' as detail_id,
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
        --ord_main_restore as ord
                do_ord as ord
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
        left join 
                mst_medicine_class as medc 
        on 
                mmd.class_cd = medc.class_cd
    where
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'' and ord.ord_no =  @ordNo
        and ''0'' =(select count(*) from ord_main where ord_no = @ordNo)
        ) as a                  
union all    
   select  
              ''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1     
   from 
        (select
      ''指示薬剤1'' as detail_id,
        mmd.medicine_name  as medi_name,
                to_number(mmxd ->> ''amount'', ''99999.99'') as counts,
        to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) as medi_amount,
        mmd.unit as medi_unit,
        mp.pricedure_name as procedure_name,
        mp.in_hospital_cd_a1 as procedure_cd1,
        mmd.in_hospital_cd_1 as medi_cd1,
        mmd.in_hospital_cd_2 as medi_cd2,
        mmd.in_hospital_cd_3 as medi_cd3,
        mmd.in_hospital_cd_4 as medi_cd4
    from
        --ord_main_restore as ord
      do_ord as ord
            CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    where 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'' and ord.ord_no =  @ordNo
        and ''0'' =(select count(*) from ord_main where ord_no = @ordNo)
        )  as a )) AS count_all1 WHERE count_all1.medi_cd1 = count_all.medi_cd1) as medi_back,
        count_all.medi_unit 
FROM (select  --ord_mainデータが存在場合
''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1
        ,case when ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd =@facilityCd 
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
      ''指示薬剤1'' as detail_id,
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
        left join 
                mst_medicine_class as medc 
        on 
                mmd.class_cd = medc.class_cd
    where
        --mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'' and
    ord.ord_no =  @ordNo)  as a 
        GROUP BY a.medi_cd1,a.medi_unit
UNION ALL
    SELECT --ord_mainデータが存在場合
                ''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1
        ,case when ''1''=(SELECT
                COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
                mst_coop_ini AS ini 
                CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd =@facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT)
         end) 
         else (sum(medi_amount::Float)*100) :: INTEGER :: TEXT end  as  medi_amount
        ,sum(counts :: INTEGER) as medi_back
        ,a.medi_unit        
        from 
        (select
      ''指示薬剤1'' as detail_id,
        mmd.medicine_name  as medi_name,
                to_number(mmxd ->> ''amount'', ''99999.99'') as counts,
        to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) as medi_amount,
        mmd.unit as medi_unit,
        mp.pricedure_name as procedure_name,
        mp.in_hospital_cd_a1 as procedure_cd1,
        mmd.in_hospital_cd_1 as medi_cd1,
        mmd.in_hospital_cd_2 as medi_cd2,
        mmd.in_hospital_cd_3 as medi_cd3,
        mmd.in_hospital_cd_4 as medi_cd4
    from
        ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    where
        --mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'' and
    ord.ord_no =  @ordNo)  as a 
        GROUP BY a.medi_cd1,a.medi_unit
union all( --ord_mainデータが存在しない場合
    select  
''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1
        ,case when ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd =@facilityCd 
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
      ''指示薬剤1'' as detail_id,
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
        --ord_main_restore as ord
                do_ord as ord
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
        left join 
                mst_medicine_class as medc 
        on 
                mmd.class_cd = medc.class_cd
    where
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'' and ord.ord_no =  @ordNo
        and ''0'' =(select count(*) from ord_main where ord_no = @ordNo)
        ) as a
         GROUP BY a.medi_cd1,a.medi_unit                 
union all    
        select  
''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1
        ,case when ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd =@facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT)
         end) 
         else (sum(medi_amount::Float)*100) :: INTEGER :: TEXT end  as  medi_amount
        ,sum(counts :: INTEGER) as medi_back
        ,a.medi_unit        
        from 
        (select
      ''指示薬剤1'' as detail_id,
        mmd.medicine_name  as medi_name,
                to_number(mmxd ->> ''amount'', ''99999.99'') as counts,
        to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) as medi_amount,
        mmd.unit as medi_unit,
        mp.pricedure_name as procedure_name,
        mp.in_hospital_cd_a1 as procedure_cd1,
        mmd.in_hospital_cd_1 as medi_cd1,
        mmd.in_hospital_cd_2 as medi_cd2,
        mmd.in_hospital_cd_3 as medi_cd3,
        mmd.in_hospital_cd_4 as medi_cd4
    from
        --ord_main_restore as ord
      do_ord as ord
            CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    where 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'' and ord.ord_no =  @ordNo
        and ''0'' =(select count(*) from ord_main where ord_no = @ordNo)
        )  as a
         GROUP BY a.medi_cd1,a.medi_unit)) AS count_all
        GROUP BY count_all.medi_cd1, count_all.medi_unit
 )
, data_all AS (
SELECT data_middle_all.detail_id, data_middle_all.medi_cd1, data_middle_all.medi_amount, data_middle_all.medi_back, data_middle_all.medi_unit 
, CASE WHEN data_middle_all.medi_cd1 IN (SELECT item_cd_m FROM do_medicine_mix) THEN do_medicine_mix.mix_M_cd ELSE mst_medicine.medicine_cd END AS medicine_cd
, CASE WHEN data_middle_all.medi_cd1 IN (SELECT item_cd_m FROM do_medicine_mix) THEN do_medicine_mix.class_M_cd ELSE mst_medicine.class_cd END AS class_cd
FROM data_middle_all 
    LEFT JOIN mst_medicine ON data_middle_all.medi_cd1 = mst_medicine.in_hospital_cd_1
        LEFT JOIN do_medicine_mix ON data_middle_all.medi_cd1 = do_medicine_mix.item_cd_m
)
, order_code_F AS (
SELECT DISTINCT ON (item_cd_f)* FROM (
  SELECT
    medi_cd1 AS item_cd_f,  
    TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS class_cd_f,
    CASE WHEN TO_NUMBER( medi_code_order :: text, ''999999999999'' ) IS NULL THEN TO_NUMBER( medicine_mix_cd :: text, ''999999999999'' ) ELSE TO_NUMBER( medi_code_order :: text, ''999999999999'' ) END AS medi_cd_f
  FROM
    data_all
    LEFT OUTER JOIN do_mstmedi_cd ON medi_code = data_all.medicine_cd
        LEFT OUTER JOIN do_medicine_mix ON item_cd_m = data_all.medi_cd1
    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = data_all.class_cd
  ORDER BY item_cd_f asc) AS order_code_middle_A    
)
, order_code_S_1 AS (
SELECT 
    CASE WHEN (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine.facility_cd = @facilityCd) IS NOT NULL 
        THEN (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine.facility_cd = @facilityCd) 
        ELSE (SELECT in_hospital_cd_1 FROM mst_medicine_mix WHERE medicine_mix_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine_mix.facility_cd = @facilityCd) END AS item_cd_s,
    TO_NUMBER( json_idx :: text, ''999999999999'' ) AS login_ord_s,
    0 AS login_ord_medicine_mix,
    TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type_s,
    (SELECT TO_NUMBER(timing_code_order :: text, ''999999999999'') FROM do_mst_timing WHERE TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'') = TO_NUMBER(timing_code :: text, ''999999999999'')) AS timing_cd_s,
    (SELECT TO_NUMBER(procedure_code_order :: text, ''999999999999'') FROM do_mst_procedure WHERE TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'') = TO_NUMBER(procedure_code :: text, ''999999999999'')) AS procedure_cd_s,
    TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval_s
 FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
 WHERE ord.ord_no = @ordNo 
UNION ALL
 SELECT 
    CASE WHEN (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine.facility_cd = @facilityCd) IS NOT NULL 
        THEN (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine.facility_cd = @facilityCd) 
        ELSE (SELECT in_hospital_cd_1 FROM mst_medicine_mix WHERE medicine_mix_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine_mix.facility_cd = @facilityCd) END AS item_cd_s,
    TO_NUMBER( json_idx :: text, ''999999999999'' ) AS login_ord_s,
    0 AS login_ord_medicine_mix,
    TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type_s,
    (SELECT TO_NUMBER(timing_code_order :: text, ''999999999999'') FROM do_mst_timing WHERE TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'') = TO_NUMBER(timing_code :: text, ''999999999999'')) AS timing_cd_s,
    (SELECT TO_NUMBER(procedure_code_order :: text, ''999999999999'') FROM do_mst_procedure WHERE TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'') = TO_NUMBER(procedure_code :: text, ''999999999999'')) AS procedure_cd_s,
    TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval_s
 FROM
    do_ord AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
 WHERE ''0'' =(select count(*) from ord_main where ord_no = @ordNo)
UNION ALL
 SELECT 
    item_cd_m AS item_cd_s,
    login_ord_m AS login_ord_s,
    ord_mk AS login_ord_medicine_mix,
    medicine_type_m AS medicine_type_s,
    timing_cd_m AS timing_cd_s,
    procedure_cd_m AS procedure_cd_s,
    date_interval_m AS date_interval_s 
 FROM do_medicine_mix
)
, order_code_S_2 AS (
SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, class_cd_f AS class_cd_s, medicine_type_s, medi_cd_f AS medi_cd_s, timing_cd_s, procedure_cd_s, date_interval_s
FROM order_code_S_1 LEFT JOIN order_code_F ON item_cd_s = item_cd_f
)
, order_code_S_3 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, class_cd_s, medicine_type_s, medi_cd_s,  timing_cd_s, procedure_cd_s, date_interval_s
FROM order_code_S_2
ORDER BY 
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval_s END) AS order_data
)
, order_code_S_dis AS (
SELECT 
    TRIM(item_cd_s) AS item_cd_s_dis,
    MIN(no2) AS ord_mk_s_dis
FROM
    order_code_S_3
GROUP BY item_cd_s_dis
ORDER BY ord_mk_s_dis
)
, order_code_S AS (
SELECT  
   no2 AS ord_mk_s, item_cd_s, login_ord_s, login_ord_medicine_mix, class_cd_s, medicine_type_s, medi_cd_s, timing_cd_s, procedure_cd_s, date_interval_s
FROM
   order_code_S_dis LEFT JOIN order_code_S_3 ON item_cd_s_dis = item_cd_s AND ord_mk_s_dis = no2
)
, dataAndOrder AS (
SELECT
    DISTINCT detail_id, medi_cd1, medi_amount, medi_back, medi_unit, 
    (SELECT login_ord_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) AS login_ord,
    (SELECT login_ord_medicine_mix FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) AS login_ord_mix,
    CASE WHEN (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) IS NULL THEN 0 ELSE (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) END AS class_cd, 
        (SELECT medicine_type_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) AS medicine_type, 
    (SELECT medi_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) AS medi_cd,        
    CASE WHEN (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) IS NULL THEN 0 ELSE (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) END AS timing_cd,       
    CASE WHEN (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) IS NULL THEN 0 ELSE (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) END AS procedure_cd, 
    CASE WHEN (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) IS NULL THEN 0 ELSE (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) END AS date_interval
FROM
    data_all
)
SELECT
    detail_id, medi_cd1, medi_amount, medi_back, medi_unit, login_ord, login_ord_mix, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
FROM
    dataAndOrder
ORDER BY 
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord_mix ELSE 0 END
limit 135', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示)中止時）投与薬剤コード', '2022-06-18 05:06:30.626', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-18, '
WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, KOU_COAG_RESOLVE_MODE_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE'')
,CREATE_NUMBER_FUNCTION_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')
,IND_COND_INFO AS (select ord.ord_no,
ord.ind_cond_info:: json ->''25'' ->> ''value'' as mix_cd,
to_number(ord.ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ord.ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99'') as mix_count
from ord_main ord where ord.ord_no = @ordNo)
, do_medicine_mix_cd AS (
SELECT index_no AS medi_mix_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_mix_code, order_cd ->> ''name'' AS medi_mix_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine_mix'' 
)
, do_mstmedi_cd AS (
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code, order_cd ->> ''name'' AS medi_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine'' 
)
, do_mstmedi_class_cd AS (
SELECT index_no AS medi_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code, order_cd ->> ''name'' AS medi_class_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine_class'' 
)
, do_mst_timing AS (
SELECT index_no AS timing_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code, order_cd ->> ''name'' AS timing_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicate_timing'' 
)
, do_mst_procedure AS (
SELECT index_no AS procedure_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code, order_cd ->> ''name'' AS procedure_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_procedure'' 
)
, do_medicine_mix_1 AS (
  SELECT
      TRIM(mmd.in_hospital_cd_1) AS item_cd,
      json_idx AS login_ord,
      TO_NUMBER( medi ->> ''class_cd'' :: text, ''999999999999'' ) AS class_M_cd,
      TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'' ) AS mix_M_cd,
      TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
      TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
      TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS medicine_mix_cd,
      TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
      TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
      TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
  FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
            LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
            LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(medi ->> ''class_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements (mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
  WHERE
      medi ->> ''medicine_type'' = ''2'' 
  AND ord.ord_no = @ordNo
)
, do_medicine_mix_2 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT item_cd, login_ord, medi_class_M_cd, medicine_type, medicine_mix_cd, timing_cd, procedure_cd, date_interval, class_M_cd, mix_M_cd 
   FROM do_medicine_mix_1
     ORDER BY 
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_mix_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END) AS order_data
)
, do_medicine_mix_dis AS (
   SELECT 
      TRIM(item_cd) AS item_cd_m_dis,
      MIN(no2) AS ord_mk_dis
   FROM
      do_medicine_mix_2
   GROUP BY item_cd_m_dis
     ORDER BY ord_mk_dis
)
, do_medicine_mix AS (
   SELECT 
      no2 AS ord_mk, item_cd AS item_cd_m, login_ord AS login_ord_m, medi_class_M_cd, medicine_type AS medicine_type_m, medicine_mix_cd, timing_cd AS timing_cd_m, procedure_cd AS procedure_cd_m, date_interval AS date_interval_m, class_M_cd, mix_M_cd
   FROM
      do_medicine_mix_dis LEFT JOIN do_medicine_mix_2 ON item_cd_m_dis = item_cd AND ord_mk_dis = no2
   
)
, data_middle_all AS (
SELECT  
    ''指示薬剤'' :: TEXT as detail_id, count_all.medi_cd1,
CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END) THEN  
                                        (SUM(count_all.medi_amount :: Float):: INTEGER :: TEXT)
                                 ELSE
                                        case when SUM(count_all.medi_amount :: Float) > 99 then (SUM(count_all.medi_amount :: Float) :: INTEGER :: TEXT)
                                        else 
                                            case when SUM(count_all.medi_amount :: Float) > 9 then ''0''||(SUM(count_all.medi_amount :: Float) :: INTEGER :: TEXT)
                                            else ''00''||(SUM(count_all.medi_amount :: Float):: INTEGER :: TEXT)
                                            end
                                        END 
                                 END as medi_amount,
    (SELECT count(count_all1.medi_cd1) FROM (select  
''指示薬剤''::TEXT as detail_id,
        a.medi_cd1    
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
        ord_main  as ord
    cross join lateral
        json_array_elements (ord.ind_medi_info :: json) medi
    left outer join
        mst_medicine as mmd on mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    left outer join
        mst_procedure as mp on mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    left join mst_medicine_class as medc on mmd.class_cd = medc.class_cd
    where
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'' and
    ord.ord_no =  @ordNo)  as a
UNION ALL
select 
''指示薬剤''::TEXT as detail_id,
TRIM(a.e01) as medi_cd1
from (
    select mmd.in_hospital_cd_1 as e01,
to_char(to_number(mix.value:: json ->> ''amount'',''999.99'')*(select mix_count from IND_COND_INFO), ''FM99990.00'' ) as e02,
mmd.unit as e03,
''1'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''9999'')
UNION ALL
    select mmd.in_hospital_cd_1 as e01,
to_char(to_number(mix.value:: json ->> ''amount'',''999.99'')*(select mix_count from IND_COND_INFO), ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''9999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
UNION ALL
select  
''指示薬剤'' :: TEXT as detail_id, a.medi_cd1
  from 
        (select
      ''指示薬剤'' as detail_id,
        mmd.medicine_name  as medi_name,
        to_number(mmxd ->> ''amount'', ''99999.99'') as counts,
        to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) as medi_amount,
        mmd.unit as medi_unit,
        mp.pricedure_name as procedure_name,
        mp.in_hospital_cd_a1 as procedure_cd1,
        mmd.in_hospital_cd_1 as medi_cd1,
        mmd.in_hospital_cd_2 as medi_cd2,
        mmd.in_hospital_cd_3 as medi_cd3,
        mmd.in_hospital_cd_4 as medi_cd4
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
   WHERE
      mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'' AND ord.ord_no = @ordNo)  AS a ) AS count_all1 WHERE count_all1.medi_cd1 = count_all.medi_cd1
        ) as medi_back
        , count_all.medi_unit 
FROM (select  
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
        ord_main  as ord
    cross join lateral
        json_array_elements (ord.ind_medi_info :: json) medi
    left outer join
        mst_medicine as mmd on mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    left outer join
        mst_procedure as mp on mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    left join mst_medicine_class as medc on mmd.class_cd = medc.class_cd
    where
--      mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'' and
    ord.ord_no =  @ordNo)  as a 
    GROUP BY a.medi_cd1,a.medi_unit
UNION ALL
select 
''指示薬剤''::TEXT as detail_id,
TRIM(a.e01) as medi_cd1,
CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END) THEN  
                                        (((a.e02::float)*100):: INTEGER :: TEXT)
                                 ELSE
                                        case when(((a.e02::float)*100)::INTEGER) > 99 then (((a.e02::float)*100) :: INTEGER :: TEXT)
                                        else 
                                            case when (((a.e02::float)*100)::INTEGER)>10 then ''0''||(((a.e02::float)*100) :: INTEGER :: TEXT)
                                            else ''00''||(((a.e02::float)*100):: INTEGER :: TEXT)
                                            end
                                        END 
                                 END as medi_amount,
TRIM(a.e03) as medi_unit 
from (
    select mmd.in_hospital_cd_1 as e01,
to_char(to_number(mix.value:: json ->> ''amount'',''999.99'')*(select mix_count from IND_COND_INFO), ''FM99990.00'' ) as e02,
mmd.unit as e03,
''1'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''9999'')

UNION ALL

    select mmd.in_hospital_cd_1 as e01,
to_char(to_number(mix.value:: json ->> ''amount'',''999.99'')*(select mix_count from IND_COND_INFO), ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''9999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
UNION ALL
select --分解調製薬剤 
''指示薬剤'' :: TEXT as detail_id, a.medi_cd1
        ,case when ''1'' = (SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')  and sum(medi_amount::Float) * 100 < 100 then 
        (case when sum(medi_amount :: Float) * 100 > 10 then ''0'' || ((sum(medi_amount :: Float) * 100) :: INTEGER :: TEXT) 
        else  ''00'' || ((sum(medi_amount :: Float) * 100) :: INTEGER :: TEXT) end) 
       else (sum(medi_amount :: Float) * 100) :: INTEGER :: TEXT end  as  medi_amount
        ,a.medi_unit       
  from 
        (select
      ''指示薬剤'' as detail_id,
        mmd.medicine_name  as medi_name,
        to_number(mmxd ->> ''amount'', ''99999.99'') as counts,
        to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''99999.99'' )), ''FM99990.00'' ) as medi_amount,
        mmd.unit as medi_unit,
        mp.pricedure_name as procedure_name,
        mp.in_hospital_cd_a1 as procedure_cd1,
        mmd.in_hospital_cd_1 as medi_cd1,
        mmd.in_hospital_cd_2 as medi_cd2,
        mmd.in_hospital_cd_3 as medi_cd3,
        mmd.in_hospital_cd_4 as medi_cd4
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
   WHERE
      mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'' AND ord.ord_no = @ordNo)  AS a 
    GROUP BY a.medi_cd1,a.medi_unit) AS count_all
GROUP BY count_all.medi_cd1, count_all.medi_unit
)
, data_all AS (
SELECT data_middle_all.detail_id, data_middle_all.medi_cd1, data_middle_all.medi_amount, data_middle_all.medi_back, data_middle_all.medi_unit 
, CASE WHEN data_middle_all.medi_cd1 IN (SELECT item_cd_m FROM do_medicine_mix) THEN do_medicine_mix.mix_M_cd ELSE mst_medicine.medicine_cd END AS medicine_cd
, CASE WHEN data_middle_all.medi_cd1 IN (SELECT item_cd_m FROM do_medicine_mix) THEN do_medicine_mix.class_M_cd ELSE mst_medicine.class_cd END AS class_cd
FROM data_middle_all 
    LEFT JOIN mst_medicine ON data_middle_all.medi_cd1 = mst_medicine.in_hospital_cd_1
        LEFT JOIN do_medicine_mix ON data_middle_all.medi_cd1 = do_medicine_mix.item_cd_m
)
, order_code_F AS (
SELECT DISTINCT ON (item_cd_f)* FROM (
  SELECT
    medi_cd1 AS item_cd_f,  
    TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS class_cd_f,
    CASE WHEN TO_NUMBER( medi_code_order :: text, ''999999999999'' ) IS NULL THEN TO_NUMBER( medicine_mix_cd :: text, ''999999999999'' ) ELSE TO_NUMBER( medi_code_order :: text, ''999999999999'' ) END AS medi_cd_f
  FROM
    data_all
    LEFT OUTER JOIN do_mstmedi_cd ON medi_code = data_all.medicine_cd
        LEFT OUTER JOIN do_medicine_mix ON item_cd_m = data_all.medi_cd1
    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = data_all.class_cd
  ORDER BY item_cd_f asc) AS order_code_middle_A    
)
, order_code_S_1 AS (
 SELECT 
    CASE WHEN (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine.facility_cd = @facilityCd) IS NOT NULL 
        THEN (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine.facility_cd = @facilityCd) 
        ELSE (SELECT in_hospital_cd_1 FROM mst_medicine_mix WHERE medicine_mix_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine_mix.facility_cd = @facilityCd) END AS item_cd_s,
    TO_NUMBER( json_idx :: text, ''999999999999'' ) AS login_ord_s,
    0 AS login_ord_medicine_mix,
    TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type_s,
    (SELECT TO_NUMBER(timing_code_order :: text, ''999999999999'') FROM do_mst_timing WHERE TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'') = TO_NUMBER(timing_code :: text, ''999999999999'')) AS timing_cd_s,
    (SELECT TO_NUMBER(procedure_code_order :: text, ''999999999999'') FROM do_mst_procedure WHERE TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'') = TO_NUMBER(procedure_code :: text, ''999999999999'')) AS procedure_cd_s,
    TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval_s
 FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
 WHERE ord.ord_no = @ordNo 
UNION ALL
 SELECT 
    item_cd_m AS item_cd_s,
    login_ord_m AS login_ord_s,
    ord_mk AS login_ord_medicine_mix,
    medicine_type_m AS medicine_type_s,
    timing_cd_m AS timing_cd_s,
    procedure_cd_m AS procedure_cd_s,
    date_interval_m AS date_interval_s 
 FROM do_medicine_mix
)
, order_code_S_2 AS (
SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, class_cd_f AS class_cd_s, medicine_type_s, medi_cd_f AS medi_cd_s, timing_cd_s, procedure_cd_s, date_interval_s
FROM order_code_S_1 LEFT JOIN order_code_F ON item_cd_s = item_cd_f
)
, order_code_S_3 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, class_cd_s, medicine_type_s, medi_cd_s,  timing_cd_s, procedure_cd_s, date_interval_s
FROM order_code_S_2
ORDER BY 
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval_s END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type_s ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN class_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medi_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd_s
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval_s END) AS order_data
)
, order_code_S_dis AS (
SELECT 
    TRIM(item_cd_s) AS item_cd_s_dis,
    MIN(no2) AS ord_mk_s_dis
FROM
    order_code_S_3
GROUP BY item_cd_s_dis
ORDER BY ord_mk_s_dis
)
, order_code_S AS (
SELECT  
   no2 AS ord_mk_s, item_cd_s, login_ord_s, login_ord_medicine_mix, class_cd_s, medicine_type_s, medi_cd_s, timing_cd_s, procedure_cd_s, date_interval_s
FROM
   order_code_S_dis LEFT JOIN order_code_S_3 ON item_cd_s_dis = item_cd_s AND ord_mk_s_dis = no2
)
, dataAndOrder AS (
SELECT  
    DISTINCT detail_id, medi_cd1, medi_amount, medi_back, medi_unit, 
    (SELECT login_ord_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) AS login_ord,
    (SELECT login_ord_medicine_mix FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) AS login_ord_mix,
    CASE WHEN (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) IS NULL THEN 0 ELSE (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) END AS class_cd, 
        (SELECT medicine_type_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) AS medicine_type, 
    (SELECT medi_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) AS medi_cd,        
    CASE WHEN (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) IS NULL THEN 0 ELSE (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) END AS timing_cd,       
    CASE WHEN (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) IS NULL THEN 0 ELSE (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) END AS procedure_cd, 
    CASE WHEN (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) IS NULL THEN 0 ELSE (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = medi_cd1) END AS date_interval
FROM
    data_all
)
SELECT
    detail_id, medi_cd1, medi_amount, medi_back, medi_unit, login_ord, login_ord_mix, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
FROM
    dataAndOrder
ORDER BY 
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord_mix ELSE 0 END,
        CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord_mix ELSE 0 END
limit 135', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示）投与薬剤コード', '2020-04-10 15:28:38.712', CURRENT_TIMESTAMP, NULL);
