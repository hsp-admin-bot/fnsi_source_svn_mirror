DELETE FROM "ntss"."sys_data_set" where sql_cd in (-18, -181, -497, -503, -19, -191, -498, -504);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES
(-18, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
),'',''))), ''999999999999'') AS a1) AS datt
)
, do_ord_main AS (
SELECT * FROM ord_main as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
)
, KOU_COAG_RESOLVE_MODE_cd AS(
    SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE''
)
, CREATE_NUMBER_FUNCTION_cd AS(
    SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION''
)
, IND_COND_INFO AS (
	select ord.ord_no,
	ord.ind_cond_info:: json ->''25'' ->> ''value'' as mix_cd, 
	ord.ind_cond_info:: json ->''25'' ->> ''medicine_type'' as mix_medicine_type, 
	to_number(ord.ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
	to_number(ord.ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99'') as mix_count
	, ord.ind_cond_info:: json ->''19'' ->> ''value'' as replace_med_cd
	, ord.ind_cond_info:: json ->''22'' ->> ''value'' as replace_med_count
	from do_ord_main AS ord
)
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
, ind_cond_info_K AS (
SELECT
      TRIM(mmd.in_hospital_cd_1) :: TEXT AS item_cd_k,
      ''3'' :: text AS first_K,
--       ''3_'' || medi_code_order :: text AS order_K
     (3+medi_code_order :: INTEGER*0.00001)::text AS order_K
  FROM
      do_ord_main AS ord
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info:: json ->''25'' ->> ''value'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN do_mstmedi_cd ON medi_code = mmd.medicine_cd
  WHERE
      ord.ind_cond_info:: json ->''25'' ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_1 AS (
    SELECT
      TRIM(mmd.in_hospital_cd_1) AS item_cd,
      json_idx AS login_ord,
      TO_NUMBER( mmx.class_cd :: text, ''999999999999'' ) AS class_M_cd,
      TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'' ) AS mix_M_cd,
      TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
      TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
      TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS medicine_mix_cd,
      TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
      TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
      TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
  FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
            LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
            LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
  WHERE
      medi ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_2_m AS (
SELECT * FROM (
    SELECT item_cd, login_ord, 
            CASE WHEN medi_class_M_cd IS NULL THEN 0 ELSE medi_class_M_cd END AS medi_class_M_cd
            , medicine_type, medicine_mix_cd, 
            CASE WHEN timing_cd IS NULL THEN 0 ELSE timing_cd END AS timing_cd,       
            CASE WHEN procedure_cd IS NULL THEN 0 ELSE procedure_cd END AS procedure_cd, 
            CASE WHEN date_interval IS NULL THEN 0 ELSE date_interval END AS date_interval, class_M_cd, mix_M_cd 
    FROM do_medicine_mix_1) AS middle_data
)
, do_medicine_mix_2 AS (
    SELECT ROW_NUMBER () OVER () AS no2, *
    FROM (SELECT *
    FROM do_medicine_mix_2_m
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
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END) AS mid_data
)
, do_medicine_mix_3 AS (
SELECT TRIM(mmd.in_hospital_cd_1) AS item_cd,
             json_idx AS login_ord,
             TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AS mix_M_cd
FROM do_ord_main AS ord
         CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
         LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
         CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
         LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE medi ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_4 AS (
        SELECT medicine_mix_cd, in_idx AS login_ord_in_mm, TRIM(mmd.in_hospital_cd_1) AS item_cd_mm
        FROM mst_medicine_mix AS mmx
                CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json) with ordinality as tmp(mmxd, in_idx)
                LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
        WHERE mmx.facility_cd = @facilityCd

AND medicine_mix_cd IN (
        SELECT mix_M_cd
        FROM do_medicine_mix_3
        GROUP BY mix_M_cd)
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
   SELECT login_ord_in_mm AS ord_mk, item_cd AS item_cd_m, login_ord AS login_ord_m, medi_class_M_cd, medicine_type AS medicine_type_m, do_medicine_mix_2.medicine_mix_cd, timing_cd AS timing_cd_m, procedure_cd AS procedure_cd_m, date_interval AS date_interval_m, class_M_cd, mix_M_cd
   FROM do_medicine_mix_dis 
                LEFT JOIN do_medicine_mix_2 ON item_cd_m_dis = item_cd AND ord_mk_dis = no2
                LEFT JOIN do_medicine_mix_4 ON do_medicine_mix_4.medicine_mix_cd = mix_M_cd 
                                                                        AND do_medicine_mix_4.item_cd_mm = item_cd
)
, middle_data AS (
SELECT  
    ''指示薬剤'' :: TEXT as detail_id, count_all.medi_cd1, count_all.medi_unit,
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
                                 END as medi_amount
from (
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
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
        do_ord_main  as ord
    cross join lateral
        json_array_elements (ord.ind_medi_info :: json) medi
    left outer join
        mst_medicine as mmd on mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    left outer join
        mst_procedure as mp on mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    left join mst_medicine_class as medc on mmd.class_cd = medc.class_cd
    where
--      mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'')  as a 
    GROUP BY a.medi_cd1,a.medi_unit
    UNION ALL
    select ''指示薬剤''::text as detail_id
	     , mm.in_hospital_cd_1 as medi_cd1
	     , CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
	            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
	            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
	            END) THEN  
	                                        (((ici.replace_med_count::float)*100):: INTEGER :: TEXT)
	                                 ELSE
	                                        case when(((ici.replace_med_count::float)*100)::INTEGER) > 99 then (((ici.replace_med_count::float)*100) :: INTEGER :: TEXT)
	                                        else 
	                                            case when (((ici.replace_med_count::float)*100)::INTEGER)>10 then ''0''||(((ici.replace_med_count::float)*100) :: INTEGER :: TEXT)
	                                            else ''00''||(((ici.replace_med_count::float)*100):: INTEGER :: TEXT)
	                                            end
	                                        END 
	                                 END as medi_amount
	     , mm.unit_second as medi_unit
	  from IND_COND_INFO ici
	       left join mst_medicine mm on mm.medicine_cd = to_number(ici.replace_med_cd, ''999999'')
	 where ici.replace_med_cd is not null
	   and ici.replace_med_cd <> ''''
UNION ALL
select 
''指示薬剤''::TEXT as detail_id,
TRIM(condinfo.e01) as medi_cd1,
CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END) THEN  
                                        (((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                 ELSE
                                        case when(((condinfo.e02::float)*100)::INTEGER) > 99 then (((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                        else 
                                            case when (((condinfo.e02::float)*100)::INTEGER)>10 then ''0''||(((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                            else ''00''||(((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                            end
                                        END 
                                 END as medi_amount,
TRIM(condinfo.e03) as medi_unit 
from (
    SELECT * FROM 
    (--①調製
SELECT *, ''1'' as e04 FROM 
(select mmd.in_hospital_cd_1 as e01,
to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM99990.00'' ) as e02,
mmd.unit as e03
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'')
) AS midd
UNION ALL
    select mmd.in_hospital_cd_1 as e01,
to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO) = ''2''
) AS condinfo

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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
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
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
   WHERE
      mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'')  AS a 
    GROUP BY a.medi_cd1,a.medi_unit
        ) AS count_all
        GROUP BY count_all.medi_cd1, count_all.medi_unit
)
, data_middle_all AS (
SELECT  
    ''指示薬剤'' :: TEXT as detail_id, count_all.medi_cd1, (SELECT middle_data.medi_amount FROM middle_data WHERE middle_data.medi_cd1 = count_all.medi_cd1
                                                  and middle_data.medi_unit = count_all.medi_unit) as medi_amount,
    (SELECT count(count_all1.medi_cd1) FROM (select  
''指示薬剤''::TEXT as detail_id,
        a.medi_cd1, a.medi_unit
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
        do_ord_main  as ord
    cross join lateral
        json_array_elements (ord.ind_medi_info :: json) medi
    left outer join
        mst_medicine as mmd on mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    left outer join
        mst_procedure as mp on mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    left join mst_medicine_class as medc on mmd.class_cd = medc.class_cd
    where
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'')  as a
	union all
	select ''指示薬剤''::TEXT as detail_id, mm.in_hospital_cd_1 as medi_cd1, mm.unit_second as medi_unit	
	  from IND_COND_INFO ici
		   left join mst_medicine mm on mm.medicine_cd = to_number(ici.replace_med_cd, ''999999'')
	 where ici.replace_med_cd is not null
	   and ici.replace_med_cd <> ''''
UNION ALL
select 
''指示薬剤''::TEXT as detail_id,
TRIM(condinfo.e01) as medi_cd1
, condinfo.e03 as medi_unit
from (
    SELECT * FROM 
    (--①調製
SELECT *, ''1'' as e04 FROM 
(select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'')
) AS midd

UNION ALL
    select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO) = ''2''
) AS condinfo
UNION ALL
select  
''指示薬剤'' :: TEXT as detail_id, a.medi_cd1, a.medi_unit as medi_unit
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
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
   WHERE
      mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'')  AS a ) AS count_all1 WHERE count_all1.medi_cd1 = count_all.medi_cd1 
                                                                                                   and count_all1.medi_unit = count_all.medi_unit
        ) as medi_back
        , count_all.medi_unit, count_all.medi_type, count_all.order_m
FROM (select DISTINCT ON (medi_cd1, medi_unit) detail_id, medi_cd1, medi_amount, medi_unit, medi_type, order_m from (
select 
''指示薬剤''::TEXT as detail_id,
TRIM(condinfo.e01) as medi_cd1,
CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END) THEN  
                                        (((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                 ELSE
                                        case when(((condinfo.e02::float)*100)::INTEGER) > 99 then (((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                        else 
                                            case when (((condinfo.e02::float)*100)::INTEGER)>10 then ''0''||(((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                            else ''00''||(((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                            end
                                        END 
                                 END as medi_amount,
TRIM(condinfo.e03) as medi_unit, ''2'' AS medi_type, ''3'' AS order_m
from (
    SELECT * FROM 
    (--①調製
SELECT *, ''1'' as e04 FROM 
(select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'')
) AS midd

UNION ALL
    select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO) = ''2''
) AS condinfo
union all
	select ''指示薬剤''::TEXT as detail_id
	     , mm.in_hospital_cd_1 as medi_cd1
	     , '''' as medi_amount
	     , mm.unit_second as medi_unit, ''1'' AS medi_type, ''4'' AS order_m
	  from IND_COND_INFO ici
	       left join mst_medicine mm on mm.medicine_cd = to_number(ici.replace_med_cd, ''999999'')
	 where ici.replace_med_cd is not null
	   and ici.replace_med_cd <> ''''
UNION ALL
select  
''指示薬剤単体''::TEXT as detail_id,
        a.medi_cd1
        ,case when ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end  
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100)::TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100)::TEXT)
         end) 
         else (sum(medi_amount::Float)*100)::TEXT end  as  medi_amount
        ,a.medi_unit, medi_type AS medi_type, ''5'' AS order_m
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
        mmd.in_hospital_cd_4 as medi_cd4,
                medi ->> ''medicine_type'' as medi_type
    from
        do_ord_main  as ord
    cross join lateral
        json_array_elements (ord.ind_medi_info :: json) medi
    left outer join
        mst_medicine as mmd on mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    left outer join
        mst_procedure as mp on mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    left join mst_medicine_class as medc on mmd.class_cd = medc.class_cd
    where
--      mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'')  as a 
    GROUP BY a.medi_cd1,a.medi_unit,a.medi_type
UNION ALL
select --分解調製薬剤 
''指示薬剤調製'' :: TEXT as detail_id, a.medi_cd1
        ,case when ''1'' = (SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info 
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0'' 
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')  and sum(medi_amount::Float) * 100 < 100 then 
        (case when sum(medi_amount :: Float) * 100 > 10 then ''0'' || ((sum(medi_amount :: Float) * 100) :: INTEGER :: TEXT) 
        else  ''00'' || ((sum(medi_amount :: Float) * 100) :: INTEGER :: TEXT) end) 
       else (sum(medi_amount :: Float) * 100) :: INTEGER :: TEXT end  as  medi_amount
        ,a.medi_unit, medi_type AS medi_type, ''5'' AS order_m
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
        mmd.in_hospital_cd_4 as medi_cd4,
                medi ->> ''medicine_type'' as medi_type
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
   WHERE
      mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'')  AS a 
    GROUP BY a.medi_cd1,a.medi_unit,a.medi_type) t_cd_group) AS count_all
GROUP BY count_all.detail_id, count_all.medi_cd1, count_all.medi_unit, count_all.medi_type, count_all.order_m
)
, data_all AS (
SELECT data_middle_all.detail_id, data_middle_all.medi_cd1, data_middle_all.medi_amount, data_middle_all.medi_back, data_middle_all.medi_unit, data_middle_all.medi_type, data_middle_all.order_m
, CASE WHEN data_middle_all.medi_type = ''2'' THEN do_medicine_mix.mix_M_cd
             WHEN data_middle_all.medi_type = ''1'' THEN mst_medicine.medicine_cd END AS medicine_cd
, CASE WHEN data_middle_all.medi_type = ''2'' THEN do_medicine_mix.class_M_cd
             WHEN data_middle_all.medi_type = ''1'' THEN mst_medicine.class_cd END AS class_cd
FROM data_middle_all 
    LEFT JOIN mst_medicine ON data_middle_all.medi_cd1 = mst_medicine.in_hospital_cd_1
    LEFT JOIN do_medicine_mix ON data_middle_all.medi_cd1 = do_medicine_mix.item_cd_m
)
, order_code_F AS (
SELECT
    medi_cd1 AS item_cd_f, medi_type AS medi_type_f, 
    TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS class_cd_f,
    CASE WHEN medi_type :: TEXT = ''2'' THEN TO_NUMBER( medicine_mix_cd :: TEXT, ''999999999999'' ) 
             WHEN medi_type :: TEXT = ''1'' THEN TO_NUMBER( medi_code_order :: TEXT, ''999999999999'' ) END AS medi_cd_f
FROM
    data_all
    LEFT OUTER JOIN do_mstmedi_cd ON medi_code = data_all.medicine_cd
    LEFT OUTER JOIN do_medicine_mix ON item_cd_m = data_all.medi_cd1
    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = data_all.class_cd
ORDER BY item_cd_f asc   
)
, order_code_S_1 AS (
 SELECT 
    CASE WHEN (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine.facility_cd = @facilityCd
) IS NOT NULL 
        THEN (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine.facility_cd = @facilityCd
) 
        ELSE (SELECT in_hospital_cd_1 FROM mst_medicine_mix WHERE medicine_mix_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AND mst_medicine_mix.facility_cd = @facilityCd
) END AS item_cd_s,
    TO_NUMBER( json_idx :: text, ''999999999999'' ) AS login_ord_s,
    0 AS login_ord_medicine_mix,
    TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type_s,
    (SELECT TO_NUMBER(timing_code_order :: text, ''999999999999'') FROM do_mst_timing WHERE TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'') = TO_NUMBER(timing_code :: text, ''999999999999'')) AS timing_cd_s,
    (SELECT TO_NUMBER(procedure_code_order :: text, ''999999999999'') FROM do_mst_procedure WHERE TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'') = TO_NUMBER(procedure_code :: text, ''999999999999'')) AS procedure_cd_s,
    TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval_s
 FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
 WHERE medi ->> ''medicine_type'' :: text = ''1''
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
SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, 
        class_cd_f AS class_cd_s, 
        medicine_type_s, 
        medi_cd_f AS medi_cd_s, 
        timing_cd_s, procedure_cd_s, date_interval_s
FROM order_code_S_1 LEFT JOIN order_code_F ON item_cd_s = item_cd_f 
                                    AND medicine_type_s :: TEXT = medi_type_f :: TEXT
)
, order_code_S_3_m AS (
    SELECT * FROM (SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, 
        CASE WHEN class_cd_s IS NULL THEN 0 ELSE class_cd_s END AS class_cd_s
        , medicine_type_s, medi_cd_s,       
        CASE WHEN timing_cd_s IS NULL THEN 0 ELSE timing_cd_s END AS timing_cd_s,       
        CASE WHEN procedure_cd_s IS NULL THEN 0 ELSE procedure_cd_s END AS procedure_cd_s, 
        CASE WHEN date_interval_s IS NULL THEN 0 ELSE date_interval_s END AS date_interval_s
 FROM order_code_S_2) AS middle_data_s
)
, order_code_S_3 AS (
    SELECT ROW_NUMBER () OVER () AS no2, *
    FROM (SELECT *
    FROM order_code_S_3_m
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
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval_s END) AS mid_data
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
        CASE WHEN order_m = ''3'' AND medi_cd1 IN (SELECT item_cd_k FROM ind_cond_info_K WHERE first_K = ''3''
				 and (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) in (''1'',''2'') ))
            THEN (SELECT order_K FROM ind_cond_info_K WHERE item_cd_k = medi_cd1) ELSE order_m END AS order_m, 
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
    detail_id, medi_cd1, medi_amount, medi_back, medi_unit, order_m, login_ord, login_ord_mix, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
FROM
    dataAndOrder
ORDER BY order_m, 
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
    login_ord_mix, medi_cd1
limit 135
',2,'[{}]','1','{"applications": [4]}',NULL,'指示）投与薬剤コード','2020-04-10 15:28:38.712',CURRENT_TIMESTAMP,NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES
(-181 ,'WITH do_order_data_from AS (
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
, do_ord_main AS (
SELECT * FROM ord_main as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
)
, IND_COND_INFO_ord_main AS (
select 
    1 AS cc,
    ord.ind_cond_info:: json ->''25'' ->> ''value'' as mix_cd, 
    ord.ind_cond_info:: json ->''25'' ->> ''medicine_type'' as mix_medicine_type, 
    to_number(ord.ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
    to_number(ord.ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99'') as mix_count
    , ord.ind_cond_info:: json ->''19'' ->> ''value'' as replace_med_cd
	, ord.ind_cond_info:: json ->''22'' ->> ''value'' as replace_med_count
from do_ord_main AS ord
)
, do_ord AS (
SELECT * FROM ord_main_restore as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
AND (SELECT COUNT(*) FROM do_ord_main) = 0
ORDER BY del_date DESC LIMIT 1
)
, IND_COND_INFO_ord_res AS (
select 
    2 AS cc,
    ord.ind_cond_info:: json ->''25'' ->> ''value'' as mix_cd, 
    ord.ind_cond_info:: json ->''25'' ->> ''medicine_type'' as mix_medicine_type, 
    to_number(ord.ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
    to_number(ord.ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99'') as mix_count
    , ord.ind_cond_info:: json ->''19'' ->> ''value'' as replace_med_cd
	, ord.ind_cond_info:: json ->''22'' ->> ''value'' as replace_med_count
from do_ord AS ord
)
, CREATE_NUMBER_FUNCTION_cd AS(
    SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION''
)
, KOU_COAG_RESOLVE_MODE_cd AS(
    SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE''
)
, ind_cond_info_K AS (
SELECT
      TRIM(mmd.in_hospital_cd_1) :: TEXT AS item_cd_k,
      ''3'' :: text AS first_K,
--       ''3_'' || medi_code_order :: text AS order_K
     (3+medi_code_order :: INTEGER*0.00001)::text AS order_K
  FROM
      IND_COND_INFO_ord_main AS ord
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.mix_cd, ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN do_mstmedi_cd ON medi_code = mmd.medicine_cd
  WHERE
      ord.mix_medicine_type = ''2'' 
UNION ALL
SELECT
      TRIM(mmd.in_hospital_cd_1) :: TEXT AS item_cd_k,
      ''3'' :: text AS first_K,
--       ''3_'' || medi_code_order :: text AS order_K
     (3+medi_code_order :: INTEGER*0.00001)::text AS order_K
  FROM
      IND_COND_INFO_ord_res AS ord
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.mix_cd, ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN do_mstmedi_cd ON medi_code = mmd.medicine_cd
  WHERE
      ord.mix_medicine_type = ''2''
        AND (SELECT COUNT(*) FROM do_ord_main) = 0
)
, do_medicine_mix_1 AS (
  SELECT
      TRIM(mmd.in_hospital_cd_1) AS item_cd,
      json_idx AS login_ord,
      TO_NUMBER( mmx.class_cd :: text, ''999999999999'' ) AS class_M_cd,
      TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'' ) AS mix_M_cd,
      TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
      TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
      TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS medicine_mix_cd,
      TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
      TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
      TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
  FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
            LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
            LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements (mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
  WHERE
      medi ->> ''medicine_type'' = ''2'' 
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
    AND ''0'' =(select count(*) from do_ord_main)
)
, do_medicine_mix_2 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT * FROM (SELECT item_cd, login_ord, 
            CASE WHEN medi_class_M_cd IS NULL THEN 0 ELSE medi_class_M_cd END AS medi_class_M_cd
            , medicine_type, medicine_mix_cd,       
            CASE WHEN timing_cd IS NULL THEN 0 ELSE timing_cd END AS timing_cd,       
            CASE WHEN procedure_cd IS NULL THEN 0 ELSE procedure_cd END AS procedure_cd, 
            CASE WHEN date_interval IS NULL THEN 0 ELSE date_interval END AS date_interval, class_M_cd, mix_M_cd 
         FROM do_medicine_mix_1) AS middle_data
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
, do_medicine_mix_3 AS (
    SELECT TRIM(mmd.in_hospital_cd_1) AS item_cd,
                 json_idx AS login_ord,
                 TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AS mix_M_cd
    FROM do_ord_main AS ord
             CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
             LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
             CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
             LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
    WHERE medi ->> ''medicine_type'' = ''2'' 
UNION
    SELECT TRIM(mmd.in_hospital_cd_1) AS item_cd,
                 json_idx AS login_ord,
                 TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AS mix_M_cd
    FROM do_ord AS ord
             CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
             LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
             CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
             LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
    WHERE medi ->> ''medicine_type'' = ''2'' 
    AND ''0'' =(select count(*) from do_ord_main)
)
, do_medicine_mix_4 AS (
SELECT medicine_mix_cd, in_idx AS login_ord_in_mm, TRIM(mmd.in_hospital_cd_1) AS item_cd_mm
FROM mst_medicine_mix AS mmx
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json) with ordinality as tmp(mmxd, in_idx)
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE mmx.facility_cd = @facilityCd
AND medicine_mix_cd IN (
        SELECT mix_M_cd
        FROM do_medicine_mix_3
        GROUP BY mix_M_cd)
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
   SELECT login_ord_in_mm AS ord_mk, item_cd AS item_cd_m, login_ord AS login_ord_m, medi_class_M_cd, medicine_type AS medicine_type_m, do_medicine_mix_2.medicine_mix_cd, timing_cd AS timing_cd_m, procedure_cd AS procedure_cd_m, date_interval AS date_interval_m, class_M_cd, mix_M_cd
   FROM do_medicine_mix_dis 
                LEFT JOIN do_medicine_mix_2 ON item_cd_m_dis = item_cd AND ord_mk_dis = no2
                LEFT JOIN do_medicine_mix_4 ON do_medicine_mix_4.medicine_mix_cd = mix_M_cd 
                                                                        AND do_medicine_mix_4.item_cd_mm = item_cd 
)
, middle_data AS (
SELECT 
    ''指示薬剤del''::TEXT as detail_id,
    count_all.medi_cd1, count_all.medi_unit,
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
                                 END as medi_amount
FROM (
select  --ord_mainデータが存在場合
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
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
        do_ord_main as ord
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
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'')  as a 
        GROUP BY a.medi_cd1,a.medi_unit
    UNION ALL
    select ''指示薬剤''::text as detail_id
	     , mm.in_hospital_cd_1 as medi_cd1
	     , CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
	            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
	            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
	            END) THEN  (((ici.replace_med_count::float)*100):: INTEGER :: TEXT)
	                 ELSE
	                   case when(((ici.replace_med_count::float)*100)::INTEGER) > 99 then (((ici.replace_med_count::float)*100) :: INTEGER :: TEXT)
	                        else 
	                          case when (((ici.replace_med_count::float)*100)::INTEGER)>10 then ''0''||(((ici.replace_med_count::float)*100) :: INTEGER :: TEXT)
	                               else ''00''||(((ici.replace_med_count::float)*100):: INTEGER :: TEXT)
	                               end
	                        END 
	                 END as medi_amount
	     , mm.unit_second as medi_unit
	  from IND_COND_INFO_ord_main ici
	       left join mst_medicine mm on mm.medicine_cd = to_number(ici.replace_med_cd, ''999999'')
	 where ici.replace_med_cd is not null
	   and ici.replace_med_cd <> ''''
UNION ALL
select --ord_mainデータが存在場合
''指示薬剤''::TEXT as detail_id,
TRIM(condinfo.e01) as medi_cd1,
CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END) THEN  
                                        (((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                 ELSE
                                        case when(((condinfo.e02::float)*100)::INTEGER) > 99 then (((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                        else 
                                            case when (((condinfo.e02::float)*100)::INTEGER)>10 then ''0''||(((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                            else ''00''||(((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                            end
                                        END 
                                 END as medi_amount,
TRIM(condinfo.e03) as medi_unit 
from (
    SELECT * FROM 
    (--①調製
SELECT *, ''1'' as e04 FROM 
(select mmd.in_hospital_cd_1 as e01,
to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM99990.00'' ) as e02,
mmd.unit as e03
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_main), ''999999'')
) AS midd

UNION ALL
    select mmd.in_hospital_cd_1 as e01,
to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_main), ''999999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO_ord_main) = ''2''
) AS condinfo
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT)
         end) 
         else (sum(medi_amount::Float)*100) :: INTEGER :: TEXT end  as  medi_amount
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
        do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    where
        --mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'')  as a 
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
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
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1''
        and ''0'' =(select count(*) from do_ord_main)
        ) as a
         GROUP BY a.medi_cd1,a.medi_unit 
    UNION ALL
    select ''指示薬剤''::text as detail_id
	     , mm.in_hospital_cd_1 as medi_cd1
	     , CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
	            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
	            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
	            END) THEN  (((ici.replace_med_count::float)*100):: INTEGER :: TEXT)
	                 ELSE
	                   case when(((ici.replace_med_count::float)*100)::INTEGER) > 99 then (((ici.replace_med_count::float)*100) :: INTEGER :: TEXT)
	                        else 
	                          case when (((ici.replace_med_count::float)*100)::INTEGER)>10 then ''0''||(((ici.replace_med_count::float)*100) :: INTEGER :: TEXT)
	                               else ''00''||(((ici.replace_med_count::float)*100):: INTEGER :: TEXT)
	                               end
	                        END 
	                 END as medi_amount
	     , mm.unit_second as medi_unit
	  from IND_COND_INFO_ord_res ici
	       left join mst_medicine mm on mm.medicine_cd = to_number(ici.replace_med_cd, ''999999'')
	 where ici.replace_med_cd is not null
	   and ici.replace_med_cd <> ''''
UNION ALL
select --ord_mainデータが存在しない場合
''指示薬剤''::TEXT as detail_id,
TRIM(condinfo.e01) as medi_cd1,
CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END) THEN  
                                        (((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                 ELSE
                                        case when(((condinfo.e02::float)*100)::INTEGER) > 99 then (((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                        else 
                                            case when (((condinfo.e02::float)*100)::INTEGER)>10 then ''0''||(((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                            else ''00''||(((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                            end
                                        END 
                                 END as medi_amount,
TRIM(condinfo.e03) as medi_unit 
from (
    SELECT * FROM 
    (--①調製
SELECT *, ''1'' as e04 FROM 
(select mmd.in_hospital_cd_1 as e01,
to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM99990.00'' ) as e02,
mmd.unit as e03
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_res), ''999999'')
) AS midd

UNION ALL
    select mmd.in_hospital_cd_1 as e01,
to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_res), ''999999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO_ord_res) = ''2''
) AS condinfo
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end  
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT)
         end) 
         else (sum(medi_amount::Float)*100) :: INTEGER :: TEXT end  as  medi_amount
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
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2''
        and ''0'' =(select count(*) from do_ord_main)
        )  as a
         GROUP BY a.medi_cd1, a.medi_unit)) AS count_all GROUP BY count_all.medi_cd1,  count_all.medi_unit
)
, data_middle_all AS (
SELECT 
        ''指示薬剤del''::TEXT as detail_id,
    count_all.medi_cd1,
                (SELECT middle_data.medi_amount FROM middle_data WHERE middle_data.medi_cd1 = count_all.medi_cd1 
                                                 and middle_data.medi_unit = count_all.medi_unit) as medi_amount,
        (SELECT count(count_all1.medi_cd1) FROM (SELECT  --ord_mainデータが存在場合
''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1, a.medi_unit        
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
        do_ord_main as ord
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
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'')  as a 
    union all
	select ''指示薬剤del''::TEXT as detail_id, mm.in_hospital_cd_1 as medi_cd1, mm.unit_second as medi_unit	
	  from IND_COND_INFO_ord_main ici
		   left join mst_medicine mm on mm.medicine_cd = to_number(ici.replace_med_cd, ''999999'')
	 where ici.replace_med_cd is not null
	   and ici.replace_med_cd <> ''''
UNION ALL
select --ord_mainデータが存在場合
''指示薬剤del''::TEXT as detail_id,
TRIM(condinfo.e01) as medi_cd1
, condinfo.e03 as medi_unit
from (
    SELECT * FROM 
    (--①調製
SELECT *, ''1'' as e04 FROM 
(select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_main), ''999999'')
) AS midd

UNION ALL
    select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_main), ''999999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO_ord_main) = ''2''
) AS condinfo
UNION ALL
    SELECT --ord_mainデータが存在場合
        ''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1, a.medi_unit as medi_unit
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
        do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    where
        --mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'')  as a 
        
union all( --ord_mainデータが存在しない場合
    select  
''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1, a.medi_unit
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
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1''
        and ''0'' =(select count(*) from do_ord_main)
        ) as a     
    union all
	select ''指示薬剤del''::TEXT as detail_id, mm.in_hospital_cd_1 as medi_cd1, mm.unit_second as medi_unit	
	  from IND_COND_INFO_ord_res ici
		   left join mst_medicine mm on mm.medicine_cd = to_number(ici.replace_med_cd, ''999999'')
	 where ici.replace_med_cd is not null
	   and ici.replace_med_cd <> ''''
UNION ALL
select --ord_mainデータが存在しない場合
''指示薬剤del''::TEXT as detail_id,
TRIM(condinfo.e01) as medi_cd1
, condinfo.e03 as medi_unit
from (
    SELECT * FROM 
    (--①調製
SELECT *, ''1'' as e04 FROM 
(select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_res), ''999999'')
) AS midd

UNION ALL
    select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_res), ''999999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO_ord_res) = ''2''
) AS condinfo
union all    
   select  
              ''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1, a.medi_unit as medi_unit     
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
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2''
        and ''0'' =(select count(*) from do_ord_main)
        )  as a )) AS count_all1 WHERE count_all1.medi_cd1 = count_all.medi_cd1 
                                   and count_all1.medi_unit = count_all.medi_unit) as medi_back,
        count_all.medi_unit, count_all.medi_type, count_all.order_m
FROM (
select DISTINCT ON (medi_cd1, medi_unit) detail_id, medi_cd1, medi_amount, medi_unit, medi_type, order_m from (
	select 
	''指示薬剤''::TEXT as detail_id,
	TRIM(condinfo.e01) as medi_cd1,
	CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END) THEN  
                                        (((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                 ELSE
                                        case when(((condinfo.e02::float)*100)::INTEGER) > 99 then (((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                        else 
                                            case when (((condinfo.e02::float)*100)::INTEGER)>10 then ''0''||(((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                            else ''00''||(((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                            end
                                        END 
                                 END as medi_amount,
TRIM(condinfo.e03) as medi_unit, ''2'' AS medi_type, ''3'' AS order_m
from (
    SELECT * FROM 
    (--①調製
SELECT *, ''1'' as e04 FROM 
(select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_main), ''999999'')
) AS midd

UNION ALL
    select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_main), ''999999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO_ord_main) = ''2''
) AS condinfo
union all
	select ''指示薬剤''::TEXT as detail_id
	     , mm.in_hospital_cd_1 as medi_cd1
	     , '''' as medi_amount
	     , mm.unit_second as medi_unit, ''1'' AS medi_type, ''4'' AS order_m
	  from IND_COND_INFO_ord_main ici
	       left join mst_medicine mm on mm.medicine_cd = to_number(ici.replace_med_cd, ''999999'')
	 where ici.replace_med_cd is not null
	   and ici.replace_med_cd <> ''''
UNION ALL
select  --ord_mainデータが存在場合
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100)::TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100)::TEXT)
         end) 
         else (sum(medi_amount::Float)*100)::TEXT end  as  medi_amount
        ,a.medi_unit, a.medi_type, ''5'' AS order_m
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
        mmd.in_hospital_cd_4 as medi_cd4,
                medi ->> ''medicine_type'' as medi_type
    from
        do_ord_main as ord
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
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1'')  as a 
        GROUP BY a.medi_cd1,a.medi_unit, a.medi_type
  union all      
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT)
         end) 
         else (sum(medi_amount::Float)*100) :: INTEGER :: TEXT end  as  medi_amount
        ,a.medi_unit, a.medi_type, ''5'' AS order_m
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
        mmd.in_hospital_cd_4 as medi_cd4,
                medi ->> ''medicine_type'' as medi_type
    from
        do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    where
        --mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2'')  as a 
        GROUP BY a.medi_cd1,a.medi_unit, a.medi_type
union all( --ord_mainデータが存在しない場合
select 
''指示薬剤''::TEXT as detail_id,
TRIM(condinfo.e01) as medi_cd1,
CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END) THEN  
                                        (((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                 ELSE
                                        case when(((condinfo.e02::float)*100)::INTEGER) > 99 then (((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                        else 
                                            case when (((condinfo.e02::float)*100)::INTEGER)>10 then ''0''||(((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                            else ''00''||(((condinfo.e02::float)*100):: INTEGER :: TEXT)
                                            end
                                        END 
                                 END as medi_amount,
TRIM(condinfo.e03) as medi_unit, ''2'' AS medi_type, ''3'' AS order_m
from (
    SELECT * FROM 
    (--①調製
SELECT *, ''1'' as e04 FROM 
(select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_res), ''999999'')
) AS midd

UNION ALL
    select mmd.in_hospital_cd_1 as e01,
to_char(1, ''FM99990.00'' ) as e02,
mmd.unit as e03,
''2'' as e04
from mst_medicine_mix as mmm cross join lateral
json_array_elements (mmm.mix_info :: json) mix left join mst_medicine as mmd 
on mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
where mmm. medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO_ord_res), ''999999'') ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO_ord_res) = ''2''
) AS condinfo
union all
	select ''指示薬剤''::TEXT as detail_id
	     , mm.in_hospital_cd_1 as medi_cd1
	     , '''' as medi_amount
	     , mm.unit as medi_unit, ''1'' AS medi_type, ''4'' AS order_m
	  from IND_COND_INFO_ord_res ici
	       left join mst_medicine mm on mm.medicine_cd = to_number(ici.replace_med_cd, ''999999'')
	 where ici.replace_med_cd is not null
	   and ici.replace_med_cd <> ''''
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end  
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100)::TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100)::TEXT)
         end) 
         else (sum(medi_amount::Float)*100)::TEXT end  as  medi_amount
        ,a.medi_unit, a.medi_type, ''5'' AS order_m
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
        mmd.in_hospital_cd_4 as medi_cd4,
                medi ->> ''medicine_type'' as medi_type
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
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''1''
        and ''0'' =(select count(*) from do_ord_main)
        ) as a
         GROUP BY a.medi_cd1,a.medi_unit, a.medi_type
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100) :: INTEGER :: TEXT)
         end) 
         else (sum(medi_amount::Float)*100) :: INTEGER :: TEXT end  as  medi_amount
        ,a.medi_unit, a.medi_type, ''5'' AS order_m
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
        mmd.in_hospital_cd_4 as medi_cd4,
                medi ->> ''medicine_type'' as medi_type
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
        mmd.in_hospital_cd_1 is not null and medi ->> ''medicine_type'' = ''2''
        and ''0'' =(select count(*) from do_ord_main)
        )  as a
         GROUP BY a.medi_cd1,a.medi_unit, a.medi_type)) t_cd_group) AS count_all
        GROUP BY count_all.medi_cd1, count_all.medi_unit, count_all.medi_type, count_all.order_m
 )
, data_all AS (
SELECT data_middle_all.detail_id, data_middle_all.medi_cd1, data_middle_all.medi_amount, data_middle_all.medi_back, data_middle_all.medi_unit, data_middle_all.medi_type, data_middle_all.order_m
, CASE WHEN data_middle_all.medi_type = ''2'' THEN do_medicine_mix.mix_M_cd
             WHEN data_middle_all.medi_type = ''1'' THEN mst_medicine.medicine_cd END AS medicine_cd
, CASE WHEN data_middle_all.medi_type = ''2'' THEN do_medicine_mix.class_M_cd
             WHEN data_middle_all.medi_type = ''1'' THEN mst_medicine.class_cd END AS class_cd
FROM data_middle_all 
    LEFT JOIN mst_medicine ON data_middle_all.medi_cd1 = mst_medicine.in_hospital_cd_1
    LEFT JOIN do_medicine_mix ON data_middle_all.medi_cd1 = do_medicine_mix.item_cd_m
)
, order_code_F AS (
  SELECT
    medi_cd1 AS item_cd_f, medi_type AS medi_type_f,
    TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS class_cd_f,
    CASE WHEN medi_type :: TEXT = ''2'' THEN TO_NUMBER( medicine_mix_cd :: TEXT, ''999999999999'' ) 
             WHEN medi_type :: TEXT = ''1'' THEN TO_NUMBER( medi_code_order :: TEXT, ''999999999999'' ) END AS medi_cd_f
  FROM
    data_all
    LEFT OUTER JOIN do_mstmedi_cd ON medi_code = data_all.medicine_cd
        LEFT OUTER JOIN do_medicine_mix ON item_cd_m = data_all.medi_cd1
    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = data_all.class_cd
  ORDER BY item_cd_f asc
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
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
 WHERE medi ->> ''medicine_type'' :: text = ''1''
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
 WHERE ''0'' =(select count(*) from do_ord_main)
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
                                    AND medicine_type_s :: TEXT = medi_type_f :: TEXT
)
, order_code_S_3_m AS (
SELECT * FROM (SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, 
            CASE WHEN class_cd_s IS NULL THEN 0 ELSE class_cd_s END AS class_cd_s
            , medicine_type_s, medi_cd_s,       
            CASE WHEN timing_cd_s IS NULL THEN 0 ELSE timing_cd_s END AS timing_cd_s,       
            CASE WHEN procedure_cd_s IS NULL THEN 0 ELSE procedure_cd_s END AS procedure_cd_s, 
            CASE WHEN date_interval_s IS NULL THEN 0 ELSE date_interval_s END AS date_interval_s
         FROM order_code_S_2) AS middle_data_s
)
, order_code_S_3 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT *
    FROM order_code_S_3_m
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
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval_s END) AS mid_data
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
        CASE WHEN order_m = ''3'' AND medi_cd1 IN (SELECT item_cd_k FROM ind_cond_info_K WHERE first_K = ''3''
				 and (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) in (''1'',''2'') ))
            THEN (SELECT order_K FROM ind_cond_info_K WHERE item_cd_k = medi_cd1) ELSE order_m END AS order_m, 
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
    detail_id, medi_cd1, medi_amount, medi_back, medi_unit, order_m, login_ord, login_ord_mix, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
FROM
    dataAndOrder
ORDER BY order_m, 
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
    login_ord_mix, medi_cd1
limit 135',2,'[{}]','1','{"applications": [4]}',NULL,'指示)中止時）投与薬剤コード','2022-06-18 05:06:30.626',CURRENT_TIMESTAMP,NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES
(-497, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, do_ord_main AS (
SELECT * FROM ord_main as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
)
, EQUIP_OUTPUT_TYPE_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
            AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE'')
, CREATE_NUMBER_FUNCTION_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
            AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')
, KOU_COAG_RESOLVE_MODE_cd AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL jsON_array_elements(ini.coop_ini_info ::jsON) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE''
)
, RST_COND_INFO AS (
SELECT ord.rst_cONd_info :: jsON ->''25'' ->> ''value'' AS mix_cd, 
             ord.rst_cONd_info :: jsON ->''25'' ->> ''medicine_type'' AS mix_medicine_type, 
             to_number(ord.rst_cONd_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ord.rst_cONd_info:: json ->''28'' ->> ''value'', ''9999.99'') as mix_count,
             CASE WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END AS falgF
    , ord.rst_cond_info:: json ->''19'' ->> ''value'' as replace_med_cd
    , ord.rst_cond_info:: json ->''22'' ->> ''unit''  as replace_med_unit
	, ord.rst_cond_info:: json ->''22'' ->> ''value'' as replace_med_count
FROM do_ord_main AS ord
)
, do_mstmedi_cd AS (
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_codmst_coop_distributee, order_cd ->> ''name'' AS medi_code_name
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
, do_medicine_mix_cd AS (
SELECT index_no AS medi_mix_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_mix_code, order_cd ->> ''name'' AS medi_mix_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine_mix'' 
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
, rst_cond_info_K AS (
SELECT
      TRIM(mmd.in_hospital_cd_1) :: TEXT AS item_cd_k,
      ''3'' :: text AS first_K,
--       ''3_'' || medi_code_order :: text AS order_K
      (3+medi_code_order :: INTEGER*0.00001)::text AS order_K
  FROM
      do_ord_main AS ord
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info:: json ->''25'' ->> ''value'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN do_mstmedi_cd ON medi_codmst_coop_distributee = mmd.medicine_cd
  WHERE
      ord.rst_cond_info:: json ->''25'' ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_1 AS (
  SELECT
      TRIM(mmd.in_hospital_cd_1) AS item_cd,
      json_idx AS login_ord,
      TO_NUMBER( mmx.class_cd :: text, ''999999999999'' ) AS class_M_cd,
      TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'' ) AS mix_M_cd,
      TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
      TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
      TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS medicine_mix_cd,
      TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
      TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
      TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
  FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
            LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
            LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements (mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
  WHERE
      medi ->> ''effect_flg'' = ''1'' 
  AND medi ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_2_m AS (
SELECT * FROM (
        SELECT item_cd, login_ord, 
            CASE WHEN medi_class_M_cd IS NULL THEN 0 ELSE medi_class_M_cd END AS medi_class_M_cd
            , medicine_type, medicine_mix_cd, 
            CASE WHEN timing_cd IS NULL THEN 0 ELSE timing_cd END AS timing_cd,       
            CASE WHEN procedure_cd IS NULL THEN 0 ELSE procedure_cd END AS procedure_cd, 
            CASE WHEN date_interval IS NULL THEN 0 ELSE date_interval END AS date_interval, class_M_cd, mix_M_cd 
    FROM do_medicine_mix_1) AS middle_data
)
, do_medicine_mix_2 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT *
    FROM do_medicine_mix_2_m
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
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END) AS mid_data
)
, do_medicine_mix_3 AS (
SELECT TRIM(mmd.in_hospital_cd_1) AS item_cd,
             json_idx AS login_ord,
             TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AS mix_M_cd
FROM do_ord_main AS ord
         CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
         LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
         CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
         LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE medi ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_4 AS (
SELECT medicine_mix_cd, in_idx AS login_ord_in_mm, TRIM(mmd.in_hospital_cd_1) AS item_cd_mm
FROM mst_medicine_mix AS mmx
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json) with ordinality as tmp(mmxd, in_idx)
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE mmx.facility_cd = @facilityCd
AND medicine_mix_cd IN (
        SELECT mix_M_cd
        FROM do_medicine_mix_3
        GROUP BY mix_M_cd)
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
      login_ord_in_mm AS ord_mk, item_cd AS item_cd_m, login_ord AS login_ord_m, medi_class_M_cd, medicine_type AS medicine_type_m, do_medicine_mix_2.medicine_mix_cd, timing_cd AS timing_cd_m, procedure_cd AS procedure_cd_m, date_interval AS date_interval_m, class_M_cd, mix_M_cd
   FROM do_medicine_mix_dis 
                LEFT JOIN do_medicine_mix_2 ON item_cd_m_dis = item_cd AND ord_mk_dis = no2
                LEFT JOIN do_medicine_mix_4 ON do_medicine_mix_4.medicine_mix_cd = mix_M_cd 
                                                                        AND do_medicine_mix_4.item_cd_mm = item_cd   
)
, middle_data AS (
SELECT
  ''薬剤'' AS detail_id,
  all_cost.e01 AS item_cd, all_cost.e05,
  (CASE WHEN all_cost.e08 = ''1'' THEN
                    (sum(all_cost.e04::float)*100::INTEGER)::text
             ELSE
                CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END)  THEN  ((sum(all_cost.e04::float)*100)::INTEGER)::text
                             ELSE
                 case when((sum(all_cost.e04::float)*100)::INTEGER)>99 then (((sum(all_cost.e04::float)*100)::INTEGER)::TEXT) 
                                else case when ((sum(all_cost.e04::float)*100)::INTEGER)>10 
                                then ''0''||(((sum(all_cost.e04::float)*100)::INTEGER)::TEXT) 
                                else ''00''||(((sum(all_cost.e04::float)*100)::INTEGER)::TEXT) end
                                end
                             END

             END) AS amount
FROM (
    (
  SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
     ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
    ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
     ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
     ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO''
 UNION ALL
   SELECT--投与薬剤情報(調製)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    to_char((to_number( medi ->> ''amount'', ''999999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
    mmd.unit AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08
   FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
  UNION ALL
    SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
      ''0'' AS e08
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    UNION ALL
    select ''投与薬剤''::TEXT as detail_id
	     , mm.in_hospital_cd_1 as e01, '''' as e02, '''' as e03
	     , rci.replace_med_count as e04, rci.replace_med_unit as e05, '''' as e06
	     , '''' as e07, ''0'' as e08
	  from RST_COND_INFO rci
	       left join mst_medicine mm on mm.medicine_cd = to_number(rci.replace_med_cd, ''999999'')
	 where rci.replace_med_cd is not null
	   and rci.replace_med_cd <> ''''
    UNION ALL
        SELECT ''投与薬剤'' AS detail_id, e01, e02, ''抗凝固剤'' AS e03, e04, e05, ''1'' AS e06, NULL AS e07, ''0'' AS e08
        FROM (
            SELECT * FROM --抗凝固剤
                (--①調製
                SELECT *, ''1'' AS e00 FROM (
                        SELECT mmd.in_hospital_cd_1 AS e01,
                                                             mmd.medicine_name AS e02,
                                                             to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM999990.00'' ) AS e04,
                                                             mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                                             mmd.medicine_name AS e02,
                                             to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM999990.00'' ) AS e04,
                                             mmd.unit AS e05,
                                             ''2'' AS e00
                FROM mst_medicine_mix AS mmm cross join lateral
                         jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                         ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS a 
        WHERE a.e00 = (SELECT cASe WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END)
        AND (SELECT mix_medicine_type FROM RST_COND_INFO) = ''2''
        ) AS rstinfo
            )) AS all_cost GROUP BY item_cd,all_cost.e08,all_cost.e05
)
, data_middle_all AS (
SELECT
  ''薬剤'' AS detail_id,
  all_cost.e01 AS item_cd,
  (SELECT middle_data.amount FROM middle_data WHERE middle_data.item_cd = all_cost.e01 and middle_data.e05 = all_cost.e05) AS amount,
  COALESCE(all_cost.e05, '''') AS unit,
    (select count(all_cost1.e01) from (SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO''
  UNION ALL
    SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
     ord.rst_cond_info -> ''8'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--          meq.unit AS e05,
    ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--      meq.unit AS e05,
ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--投与薬剤情報(調製)
      ''投与薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e1,
      mmd.medicine_name AS e2,
      mmdc.class_name AS e03,
      to_char((to_number( medi ->> ''amount'', ''999999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
      mmd.unit AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07,
          ''0'' AS e08  
   FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
   WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
  UNION ALL
    SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
            ''0'' AS e08
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    UNION ALL
     select ''投与薬剤''::TEXT as detail_id
	     , mm.in_hospital_cd_1 as e01, '''' as e02, '''' as e03
	     , '''' as e04, rci.replace_med_unit as e05, '''' as e06
	     , '''' as e07, '''' as e08
	  from RST_COND_INFO rci
	       left join mst_medicine mm on mm.medicine_cd = to_number(rci.replace_med_cd, ''999999'')
	 where rci.replace_med_cd is not null
	   and rci.replace_med_cd <> ''''
    UNION ALL
        SELECT ''投与薬剤'' AS detail_id, e01, e02, ''抗凝固剤'' AS e03, e04, e05, ''1'' AS e06, NULL AS e07, ''0'' AS e08
        FROM (
            SELECT * FROM --抗凝固剤
                (--①調製
                SELECT *, ''1'' AS e00 FROM (
                        SELECT mmd.in_hospital_cd_1 AS e01,
                                     mmd.medicine_name AS e02,
                                     to_char(1, ''FM999990.00'' ) AS e04,
                                     mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                             mmd.medicine_name AS e02,
                             to_char(1, ''FM999990.00'' ) AS e04,
                             mmd.unit AS e05,
                             ''2'' AS e00
                FROM mst_medicine_mix AS mmm cross join lateral
                         jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                         ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS a 
        WHERE a.e00 = (SELECT cASe WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END)
        AND (SELECT mix_medicine_type FROM RST_COND_INFO) = ''2''
        ) AS rstinfo
            ) as all_cost1 where all_cost1.e01 = all_cost.e01 
                             and all_cost1.e05 = all_cost.e05) count
            , all_cost.e09 AS cond_info_jyun, medi_type AS medi_type
FROM
  (
  SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    ''1'' AS e09,
        ''1'' AS medi_type
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''8'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    ''2'' AS e09,
        ''1'' AS medi_type
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    ''0'' AS e09,
      ''1'' AS medi_type
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08,
    ''5'' AS e09,
    medi ->> ''medicine_type'' AS medi_type
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO''
 UNION ALL
   SELECT--投与薬剤情報(調製)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    to_char((to_number( medi ->> ''amount'', ''999999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
    mmd.unit AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08, 
    ''5'' AS e09,
    medi ->> ''medicine_type'' AS medi_type
   FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
  UNION ALL
    SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
      ''0'' AS e08,
      ''5'' AS e09,
      ''1'' AS medi_type
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    UNION ALL
    select ''投与薬剤''::TEXT as detail_id
	     , mm.in_hospital_cd_1 as e01, '''' as e02, '''' as e03
	     , '''' as e04, rci.replace_med_unit as e05, '''' as e06
	     , '''' as e07, '''' as e08, ''4'' as e09, ''1'' AS medi_type
	  from RST_COND_INFO rci
	       left join mst_medicine mm on mm.medicine_cd = to_number(rci.replace_med_cd, ''999999'')
	 where rci.replace_med_cd is not null
	   and rci.replace_med_cd <> ''''
    UNION ALL
        SELECT ''投与薬剤'' AS detail_id, e01, e02, ''抗凝固剤'' AS e03, e04, e05, ''1'' AS e06, NULL AS e07, ''0'' AS e08, ''3'' AS e09, (SELECT mix_medicine_type FROM RST_COND_INFO) AS medi_type
        FROM (
            SELECT * FROM --抗凝固剤
                (--①調製
                SELECT *, ''1'' AS e00 FROM (
                        SELECT mmd.in_hospital_cd_1 AS e01,
                                     mmd.medicine_name AS e02,
                                     to_char(1, ''FM999990.00'' ) AS e04,
                                     mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                             mmd.medicine_name AS e02,
                             to_char(1, ''FM999990.00'' ) AS e04,
                             mmd.unit AS e05,
                             ''2'' AS e00
                FROM mst_medicine_mix AS mmm cross join lateral
                         jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                         ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS a 
        WHERE a.e00 = (SELECT cASe WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END)
        AND (SELECT mix_medicine_type FROM RST_COND_INFO) = ''2''
        ) AS rstinfo
            ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
    group by all_cost.e01,all_cost.e05,all_cost.e08,all_cost.e09,all_cost.medi_type
)
, data_all AS (
SELECT data_middle_all.detail_id, data_middle_all.item_cd, data_middle_all.amount, data_middle_all.unit, data_middle_all.count, data_middle_all.cond_info_jyun, data_middle_all.medi_type 
, CASE WHEN data_middle_all.medi_type = ''2'' THEN do_medicine_mix.mix_M_cd
             WHEN data_middle_all.medi_type = ''1'' THEN mst_medicine.medicine_cd END AS medicine_cd
, CASE WHEN data_middle_all.medi_type = ''2'' THEN do_medicine_mix.class_M_cd
             WHEN data_middle_all.medi_type = ''1'' THEN mst_medicine.class_cd END AS class_cd
FROM data_middle_all 
    LEFT JOIN mst_medicine ON data_middle_all.item_cd = mst_medicine.in_hospital_cd_1
        LEFT JOIN do_medicine_mix ON data_middle_all.item_cd = do_medicine_mix.item_cd_m
)
, order_code_F AS (
  SELECT
    item_cd AS item_cd_f, medi_type AS medi_type_f, 
    TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS class_cd_f,
    CASE WHEN medi_type :: TEXT = ''2'' THEN TO_NUMBER( medicine_mix_cd :: TEXT, ''999999999999'' ) 
             WHEN medi_type :: TEXT = ''1'' THEN TO_NUMBER( medi_code_order :: TEXT, ''999999999999'' ) END AS medi_cd_f
  FROM
    data_all
    LEFT OUTER JOIN do_mstmedi_cd ON medi_codmst_coop_distributee = data_all.medicine_cd
    LEFT OUTER JOIN do_medicine_mix ON item_cd_m = data_all.item_cd
    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = data_all.class_cd
  ORDER BY item_cd_f asc   
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
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx) 
 WHERE medi ->> ''medicine_type'' :: text = ''1''   
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
                                    AND medicine_type_s :: TEXT = medi_type_f :: TEXT
)
, order_code_S_3_m AS (
SELECT * FROM (SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, 
            CASE WHEN class_cd_s IS NULL THEN 0 ELSE class_cd_s END AS class_cd_s
            , medicine_type_s, medi_cd_s,       
            CASE WHEN timing_cd_s IS NULL THEN 0 ELSE timing_cd_s END AS timing_cd_s,       
            CASE WHEN procedure_cd_s IS NULL THEN 0 ELSE procedure_cd_s END AS procedure_cd_s, 
            CASE WHEN date_interval_s IS NULL THEN 0 ELSE date_interval_s END AS date_interval_s
         FROM order_code_S_2) AS middle_data_s
)
, order_code_S_3 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT *
    FROM order_code_S_3_m
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
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval_s END) AS mid_data
)
, order_code_S_dis AS (
SELECT 
    TRIM(item_cd_s) AS item_cd_s_dis,
    MIN(no2) AS ord_mk_s_dis
FROM
    order_code_S_3
WHERE TRIM(item_cd_s) IS NOT NULL
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
SELECT DISTINCT ON (item_cd, unit)* FROM (
SELECT
    detail_id, item_cd, amount, unit, count, 
        CASE WHEN cond_info_jyun = ''3'' AND item_cd IN (SELECT item_cd_k FROM rst_cond_info_K WHERE first_K = ''3''
 and (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) in (''1'',''2'') ) ) 
            THEN (SELECT order_K FROM rst_cond_info_K WHERE item_cd_k = item_cd) ELSE cond_info_jyun END AS cond_info_jyun,             
    (SELECT login_ord_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS login_ord,
    (SELECT login_ord_medicine_mix FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS login_ord_mix,
    CASE WHEN (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS class_cd, 
        (SELECT medicine_type_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medicine_type, 
    (SELECT medi_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medi_cd,        
    CASE WHEN (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS timing_cd,       
    CASE WHEN (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS procedure_cd, 
    CASE WHEN (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS date_interval
FROM
    data_all ORDER BY cond_info_jyun) AS order_middle 
)
SELECT
    detail_id, item_cd, amount, unit, count, cond_info_jyun, login_ord, login_ord_mix, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
FROM
    dataAndOrder
ORDER BY cond_info_jyun,
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
    login_ord_mix, item_cd
limit 135
',2,'[{}]','1','{"applications": [4]}',NULL,'日機装)実績）薬剤の投薬回数のSQL)','2022-05-09 05:52:21.853',CURRENT_TIMESTAMP,NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES
(-503, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, do_ord_main AS (
  (SELECT
    ord_i.del_date as up_date_switch,
    ord_i.rst_cond_info AS rst_cond_info,
    ord_i.rst_medi_info AS rst_medi_info,
    ord_i.rst_treatment_info AS rst_treatment_info
  FROM ord_main_restore as ord_i
  JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
  WHERE ord_i.ord_no = @ordNo
    AND journal.ctl_no = @ctlNo
    AND ord_i.ord_no = journal.ord_no
    AND journal.reg_date >= ord_i.del_date
  ORDER BY ord_i.del_date DESC LIMIT 1)
UNION
  (SELECT
    ord_i.rst_edition_date as up_date_switch,
    ord_i.rst_cond_info AS rst_cond_info,
    ord_i.rst_medi_info AS rst_medi_info,
    ord_i.rst_treatment_info AS rst_treatment_info
  FROM ord_main AS ord_i
  WHERE ord_i.ord_no = @ordNo)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, EQUIP_OUTPUT_TYPE_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
            AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE'')
, CREATE_NUMBER_FUNCTION_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
            AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')
, KOU_COAG_RESOLVE_MODE_cd AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL jsON_array_elements(ini.coop_ini_info ::jsON) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE''
)
, RST_COND_INFO AS (
SELECT ord.rst_cONd_info :: jsON ->''25'' ->> ''value'' AS mix_cd, 
             ord.rst_cONd_info :: jsON ->''25'' ->> ''medicine_type'' AS mix_medicine_type, 
             to_number(ord.rst_cONd_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ord.rst_cONd_info:: json ->''28'' ->> ''value'', ''9999.99'') as mix_count,
             CASE WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END AS falgF
    , ord.rst_cond_info:: json ->''19'' ->> ''value'' as replace_med_cd
    , ord.rst_cond_info:: json ->''22'' ->> ''unit''  as replace_med_unit
	, ord.rst_cond_info:: json ->''22'' ->> ''value'' as replace_med_count
FROM do_ord_main AS ord
)
, do_mstmedi_cd AS (
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_codmst_coop_distributee, order_cd ->> ''name'' AS medi_code_name
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
, do_medicine_mix_cd AS (
SELECT index_no AS medi_mix_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_mix_code, order_cd ->> ''name'' AS medi_mix_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_medicine_mix'' 
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
, rst_cond_info_K AS (
SELECT
      TRIM(mmd.in_hospital_cd_1) :: TEXT AS item_cd_k,
      ''3'' :: text AS first_K,
--       ''3_'' || medi_code_order :: text AS order_K
      (3+medi_code_order :: INTEGER*0.00001)::text AS order_K
  FROM
      do_ord_main AS ord
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info:: json ->''25'' ->> ''value'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN do_mstmedi_cd ON medi_codmst_coop_distributee = mmd.medicine_cd
  WHERE
      ord.rst_cond_info:: json ->''25'' ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_1 AS (
  SELECT
      TRIM(mmd.in_hospital_cd_1) AS item_cd,
      json_idx AS login_ord,
      TO_NUMBER( mmx.class_cd :: text, ''999999999999'' ) AS class_M_cd,
      TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'' ) AS mix_M_cd,
      TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
      TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
      TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS medicine_mix_cd,
      TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
      TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
      TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
  FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
            LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
            LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
            LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements (mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
  WHERE
      medi ->> ''effect_flg'' = ''1'' 
  AND medi ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_2_m AS (
SELECT * FROM (
        SELECT item_cd, login_ord, 
            CASE WHEN medi_class_M_cd IS NULL THEN 0 ELSE medi_class_M_cd END AS medi_class_M_cd
            , medicine_type, medicine_mix_cd, 
            CASE WHEN timing_cd IS NULL THEN 0 ELSE timing_cd END AS timing_cd,       
            CASE WHEN procedure_cd IS NULL THEN 0 ELSE procedure_cd END AS procedure_cd, 
            CASE WHEN date_interval IS NULL THEN 0 ELSE date_interval END AS date_interval, class_M_cd, mix_M_cd 
    FROM do_medicine_mix_1) AS middle_data
)
, do_medicine_mix_2 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT *
    FROM do_medicine_mix_2_m
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
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END) AS mid_data
)
, do_medicine_mix_3 AS (
SELECT TRIM(mmd.in_hospital_cd_1) AS item_cd,
             json_idx AS login_ord,
             TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AS mix_M_cd
FROM do_ord_main AS ord
         CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
         LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
         CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
         LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE medi ->> ''medicine_type'' = ''2'' 
)
, do_medicine_mix_4 AS (
SELECT medicine_mix_cd, in_idx AS login_ord_in_mm, TRIM(mmd.in_hospital_cd_1) AS item_cd_mm
FROM mst_medicine_mix AS mmx
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json) with ordinality as tmp(mmxd, in_idx)
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE mmx.facility_cd = @facilityCd
AND medicine_mix_cd IN (
        SELECT mix_M_cd
        FROM do_medicine_mix_3
        GROUP BY mix_M_cd)
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
      login_ord_in_mm AS ord_mk, item_cd AS item_cd_m, login_ord AS login_ord_m, medi_class_M_cd, medicine_type AS medicine_type_m, do_medicine_mix_2.medicine_mix_cd, timing_cd AS timing_cd_m, procedure_cd AS procedure_cd_m, date_interval AS date_interval_m, class_M_cd, mix_M_cd
   FROM do_medicine_mix_dis 
                LEFT JOIN do_medicine_mix_2 ON item_cd_m_dis = item_cd AND ord_mk_dis = no2
                LEFT JOIN do_medicine_mix_4 ON do_medicine_mix_4.medicine_mix_cd = mix_M_cd 
                                                                        AND do_medicine_mix_4.item_cd_mm = item_cd   
)
, middle_data AS (
SELECT
  ''薬剤del'' AS detail_id,
  all_cost.e01 AS item_cd, all_cost.e05,
  (CASE WHEN all_cost.e08 = ''1'' THEN
                    (sum(all_cost.e04::float)*100::INTEGER)::text
             ELSE
                CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END)  THEN  ((sum(all_cost.e04::float)*100)::INTEGER)::text
                             ELSE
                 case when((sum(all_cost.e04::float)*100)::INTEGER)>99 then (((sum(all_cost.e04::float)*100)::INTEGER)::TEXT) 
                                else case when ((sum(all_cost.e04::float)*100)::INTEGER)>10 
                                then ''0''||(((sum(all_cost.e04::float)*100)::INTEGER)::TEXT) 
                                else ''00''||(((sum(all_cost.e04::float)*100)::INTEGER)::TEXT) end
                                end
                             END

             END) AS amount
FROM (
    (
  SELECT--1次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
     ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--2次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
    ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--吸着カラム情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
     ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
     ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--投与薬剤情報(通常)
    ''薬剤del'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO''
 UNION ALL
   SELECT--投与薬剤情報(調製)
    ''薬剤del'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    to_char((to_number( medi ->> ''amount'', ''999999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
    mmd.unit AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08
   FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
  UNION ALL
    SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
      ''0'' AS e08
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    UNION ALL
    select ''薬剤del''::TEXT as detail_id
	     , mm.in_hospital_cd_1 as e01, '''' as e02, '''' as e03
	     , rci.replace_med_count as e04, rci.replace_med_unit as e05, '''' as e06
	     , '''' as e07, ''0'' as e08
	  from RST_COND_INFO rci
	       left join mst_medicine mm on mm.medicine_cd = to_number(rci.replace_med_cd, ''999999'')
	 where rci.replace_med_cd is not null
	   and rci.replace_med_cd <> ''''
    UNION ALL
        SELECT ''薬剤del'' AS detail_id, e01, e02, ''抗凝固剤'' AS e03, e04, e05, ''1'' AS e06, NULL AS e07, ''0'' AS e08
        FROM (
            SELECT * FROM --抗凝固剤
                (--①調製
                SELECT *, ''1'' AS e00 FROM (
                        SELECT mmd.in_hospital_cd_1 AS e01,
                                                             mmd.medicine_name AS e02,
                                                             to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM999990.00'' ) AS e04,
                                                             mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                                             mmd.medicine_name AS e02,
                                             to_char(1 * TO_NUMBER (mix ->> ''amount'',''999999999999.99''), ''FM999990.00'' ) AS e04,
                                             mmd.unit AS e05,
                                             ''2'' AS e00
                FROM mst_medicine_mix AS mmm cross join lateral
                         jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                         ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS a 
        WHERE a.e00 = (SELECT cASe WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END)
        AND (SELECT mix_medicine_type FROM RST_COND_INFO) = ''2''
        ) AS rstinfo
            )) AS all_cost GROUP BY item_cd,all_cost.e08,all_cost.e05
)
, data_middle_all AS (
SELECT
  ''薬剤del'' AS detail_id,
  all_cost.e01 AS item_cd,
  (SELECT middle_data.amount FROM middle_data WHERE middle_data.item_cd = all_cost.e01 and middle_data.e05 = all_cost.e05) AS amount,
  COALESCE(all_cost.e05, '''') AS unit,
    (select count(all_cost1.e01) from (SELECT--投与薬剤情報(通常)
    ''薬剤del'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO''
  UNION ALL
    SELECT--1次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--2次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
     ord.rst_cond_info -> ''8'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--          meq.unit AS e05,
    ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--吸着カラム情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--      meq.unit AS e05,
ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
        ''0'' AS e08
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
    SELECT--投与薬剤情報(調製)
      ''薬剤del'' AS detail_id,
      mmd.in_hospital_cd_1 AS e1,
      mmd.medicine_name AS e2,
      mmdc.class_name AS e03,
      to_char((to_number( medi ->> ''amount'', ''999999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
      mmd.unit AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07,
          ''0'' AS e08  
   FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
   WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
  UNION ALL
    SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
            ''0'' AS e08
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    UNION ALL
     select ''薬剤del''::TEXT as detail_id
	     , mm.in_hospital_cd_1 as e01, '''' as e02, '''' as e03
	     , '''' as e04, rci.replace_med_unit as e05, '''' as e06
	     , '''' as e07, '''' as e08
	  from RST_COND_INFO rci
	       left join mst_medicine mm on mm.medicine_cd = to_number(rci.replace_med_cd, ''999999'')
	 where rci.replace_med_cd is not null
	   and rci.replace_med_cd <> ''''
    UNION ALL
        SELECT ''薬剤del'' AS detail_id, e01, e02, ''抗凝固剤'' AS e03, e04, e05, ''1'' AS e06, NULL AS e07, ''0'' AS e08
        FROM (
            SELECT * FROM --抗凝固剤
                (--①調製
                SELECT *, ''1'' AS e00 FROM (
                        SELECT mmd.in_hospital_cd_1 AS e01,
                                     mmd.medicine_name AS e02,
                                     to_char(1, ''FM999990.00'' ) AS e04,
                                     mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                             mmd.medicine_name AS e02,
                             to_char(1, ''FM999990.00'' ) AS e04,
                             mmd.unit AS e05,
                             ''2'' AS e00
                FROM mst_medicine_mix AS mmm cross join lateral
                         jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                         ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS a 
        WHERE a.e00 = (SELECT cASe WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END)
        AND (SELECT mix_medicine_type FROM RST_COND_INFO) = ''2''
        ) AS rstinfo
            ) as all_cost1 where all_cost1.e01 = all_cost.e01 
                             and all_cost1.e05 = all_cost.e05) count
            , all_cost.e09 AS cond_info_jyun, medi_type AS medi_type
FROM
  (
  SELECT--1次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
ord.rst_cond_info -> ''7'' ->> ''value_name_1'' AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''7'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    ''1'' AS e09,
        ''1'' AS medi_type
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--2次膜情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''8'' ->> ''value_name_1'' AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''8'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    ''2'' AS e09,
        ''1'' AS medi_type
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--吸着カラム情報
    ''薬剤del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
--     meq.equipment_name AS e02,
    ord.rst_cond_info -> ''6'' ->> ''value_name_1'' AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
--     meq.unit AS e05,
ord.rst_cond_info -> ''6'' ->> ''unit'' AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07,
    ''0'' AS e08,
    ''0'' AS e09,
      ''1'' AS medi_type
  FROM
    do_ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ''1''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
            (select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
            then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
            END)
  UNION ALL
   SELECT--投与薬剤情報(通常)
    ''薬剤del'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08,
    ''5'' AS e09,
    medi ->> ''medicine_type'' AS medi_type
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
  WHERE
    medi ->> ''effect_flg'' = ''1''
    AND medi ->> ''medicine_type'' = ''1''
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO''
 UNION ALL
   SELECT--投与薬剤情報(調製)
    ''薬剤del'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    to_char((to_number( medi ->> ''amount'', ''99999.99'' ) * to_number( mmxd ->> ''amount'', ''999999.99'' )), ''FM999990.00'' ) AS e04,
    mmd.unit AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07,
    ''0'' AS e08, 
    ''5'' AS e09,
    medi ->> ''medicine_type'' AS medi_type
   FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
  UNION ALL
    SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''999999.99'' ), ''FM999990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07,
      ''0'' AS e08,
      ''5'' AS e09,
      ''1'' AS medi_type
    FROM
      do_ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    UNION ALL
    select ''薬剤del''::TEXT as detail_id
	     , mm.in_hospital_cd_1 as e01, '''' as e02, '''' as e03
	     , '''' as e04, rci.replace_med_unit as e05, '''' as e06
	     , '''' as e07, '''' as e08, ''4'' as e09, ''1'' AS medi_type
	  from RST_COND_INFO rci
	       left join mst_medicine mm on mm.medicine_cd = to_number(rci.replace_med_cd, ''999999'')
	 where rci.replace_med_cd is not null
	   and rci.replace_med_cd <> ''''
    UNION ALL
        SELECT ''薬剤del'' AS detail_id, e01, e02, ''抗凝固剤'' AS e03, e04, e05, ''1'' AS e06, NULL AS e07, ''0'' AS e08, ''3'' AS e09, (SELECT mix_medicine_type FROM RST_COND_INFO) AS medi_type
        FROM (
            SELECT * FROM --抗凝固剤
                (--①調製
                SELECT *, ''1'' AS e00 FROM (
                        SELECT mmd.in_hospital_cd_1 AS e01,
                                     mmd.medicine_name AS e02,
                                     to_char(1, ''FM999990.00'' ) AS e04,
                                     mmd.unit AS e05
                        FROM mst_medicine_mix AS mmm cross join lateral
                                 jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                                 ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                        WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS midd

            UNION ALL
                SELECT mmd.in_hospital_cd_1 AS e01,
                             mmd.medicine_name AS e02,
                             to_char(1, ''FM999990.00'' ) AS e04,
                             mmd.unit AS e05,
                             ''2'' AS e00
                FROM mst_medicine_mix AS mmm cross join lateral
                         jsON_array_elements (mmm.mix_info :: jsON) mix left join mst_medicine AS mmd 
                         ON mmd.medicine_cd = TO_NUMBER (mix ->> ''cd'',''999999999999'')
                WHERE mmm. medicine_mix_cd = to_number((SELECT mix_cd FROM RST_COND_INFO), ''999999'') ) AS a 
        WHERE a.e00 = (SELECT cASe WHEN (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
                        (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) = ''''
                        THEN  ''0'' ELSE (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) END)
        AND (SELECT mix_medicine_type FROM RST_COND_INFO) = ''2''
        ) AS rstinfo
            ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
    group by all_cost.e01,all_cost.e05,all_cost.e08,all_cost.e09,all_cost.medi_type
)
, data_all AS (
SELECT data_middle_all.detail_id, data_middle_all.item_cd, data_middle_all.amount, data_middle_all.unit, data_middle_all.count, data_middle_all.cond_info_jyun, data_middle_all.medi_type 
, CASE WHEN data_middle_all.medi_type = ''2'' THEN do_medicine_mix.mix_M_cd
             WHEN data_middle_all.medi_type = ''1'' THEN mst_medicine.medicine_cd END AS medicine_cd
, CASE WHEN data_middle_all.medi_type = ''2'' THEN do_medicine_mix.class_M_cd
             WHEN data_middle_all.medi_type = ''1'' THEN mst_medicine.class_cd END AS class_cd
FROM data_middle_all 
    LEFT JOIN mst_medicine ON data_middle_all.item_cd = mst_medicine.in_hospital_cd_1
        LEFT JOIN do_medicine_mix ON data_middle_all.item_cd = do_medicine_mix.item_cd_m
)
, order_code_F AS (
  SELECT
    item_cd AS item_cd_f, medi_type AS medi_type_f, 
    TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS class_cd_f,
    CASE WHEN medi_type :: TEXT = ''2'' THEN TO_NUMBER( medicine_mix_cd :: TEXT, ''999999999999'' ) 
             WHEN medi_type :: TEXT = ''1'' THEN TO_NUMBER( medi_code_order :: TEXT, ''999999999999'' ) END AS medi_cd_f
  FROM
    data_all
    LEFT OUTER JOIN do_mstmedi_cd ON medi_codmst_coop_distributee = data_all.medicine_cd
    LEFT OUTER JOIN do_medicine_mix ON item_cd_m = data_all.item_cd
    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = data_all.class_cd
  ORDER BY item_cd_f asc   
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
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx) 
 WHERE medi ->> ''medicine_type'' :: text = ''1''   
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
                                    AND medicine_type_s :: TEXT = medi_type_f :: TEXT
)
, order_code_S_3_m AS (
SELECT * FROM (SELECT item_cd_s, login_ord_s, login_ord_medicine_mix, 
            CASE WHEN class_cd_s IS NULL THEN 0 ELSE class_cd_s END AS class_cd_s
            , medicine_type_s, medi_cd_s,       
            CASE WHEN timing_cd_s IS NULL THEN 0 ELSE timing_cd_s END AS timing_cd_s,       
            CASE WHEN procedure_cd_s IS NULL THEN 0 ELSE procedure_cd_s END AS procedure_cd_s, 
            CASE WHEN date_interval_s IS NULL THEN 0 ELSE date_interval_s END AS date_interval_s
         FROM order_code_S_2) AS middle_data_s
)
, order_code_S_3 AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT *
    FROM order_code_S_3_m
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
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval_s END) AS mid_data
)
, order_code_S_dis AS (
SELECT 
    TRIM(item_cd_s) AS item_cd_s_dis,
    MIN(no2) AS ord_mk_s_dis
FROM
    order_code_S_3
WHERE TRIM(item_cd_s) IS NOT NULL
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
SELECT DISTINCT ON (item_cd, unit)* FROM (
SELECT
    detail_id, item_cd, amount, unit, count, 
        CASE WHEN cond_info_jyun = ''3'' AND item_cd IN (SELECT item_cd_k FROM rst_cond_info_K WHERE first_K = ''3''
 and (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) in (''1'',''2'') ) ) 
            THEN (SELECT order_K FROM rst_cond_info_K WHERE item_cd_k = item_cd) ELSE cond_info_jyun END AS cond_info_jyun,             
    (SELECT login_ord_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS login_ord,
    (SELECT login_ord_medicine_mix FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS login_ord_mix,
    CASE WHEN (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT class_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS class_cd, 
        (SELECT medicine_type_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medicine_type, 
    (SELECT medi_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) AS medi_cd,        
    CASE WHEN (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS timing_cd,       
    CASE WHEN (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS procedure_cd, 
    CASE WHEN (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) IS NULL THEN 0 ELSE (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = item_cd) END AS date_interval
FROM
    data_all ORDER BY cond_info_jyun) AS order_middle 
)
SELECT
    detail_id, item_cd, amount, unit, count, cond_info_jyun, login_ord, login_ord_mix, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
FROM
    dataAndOrder
ORDER BY cond_info_jyun,
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
    login_ord_mix, item_cd
limit 135
',2,'[{}]','1','{"applications": [4]}',NULL,'日機装)実績)中止時）薬剤の投薬回数のSQL)','2022-07-27 01:34:23.644',CURRENT_TIMESTAMP,NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES
(-19 ,'WITH do_order_data_from AS (SELECT ROW_NUMBER() OVER () AS no2, datt.ora::numeric
                            FROM (SELECT jsonb_array_elements_text(mst_f.value::jsonb) AS ora
                                  FROM mst_facility_setting AS mst_f
                                  WHERE mst_f.facility_setting_no = ''3006''
                                    AND mst_f.facility_cd = @facilityCd) AS datt)
   , do_mstmeq_cd AS (SELECT index_no                                       AS meq_code_order,
                             TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code,
                             order_cd ->> ''name''                            AS meq_code_name
                      FROM mst_selector
                               CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
                      WHERE facility_cd = @facilityCd
                        AND master_physical_name = ''mst_equipment'')
   , do_mstmeq_class_cd AS (SELECT index_no                                       AS meq_class_code_order,
                                   TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code,
                                   order_cd ->> ''name''                            AS meq_class_code_name
                            FROM mst_selector
                                     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
                            WHERE facility_cd = @facilityCd
                              AND master_physical_name = ''mst_equipment_class'')
   , data_middle_all AS (select ''指示医材''                                          as detail_id,
                                row_number() over ()                                as equip_no,
                                all_equip.equip_class_type                          as class,
                                all_equip.cd1                                       as cd1,
                                all_equip.cd2                                       as cd2,
                                all_equip.cd3                                       as cd3,
                                all_equip.cd4                                       as cd4,
                                all_equip.equip_name                                as name,
                                ((COALESCE(all_equip.amount, ''0'')::FLOAT))::INTEGER AS amount,
                                all_equip.unit                                      as unit,
                                all_equip.syoumouhinOrder                           as syoumouhinOrder
                         from (select ''吸着器''                     as equip_class_type,
                                      meqad.equipment_name         as equip_name,
                                      trim(meqad.in_hospital_cd_1) as cd1,--吸着器コード１
                                      trim(meqad.in_hospital_cd_2) as cd2,
                                      trim(meqad.in_hospital_cd_3) as cd3,
                                      trim(meqad.in_hospital_cd_4) as cd4,
                                      ''1''                          as amount,
                                      meqad.unit,
                                      1                            as syoumouhinOrder
                               from ord_main as ord
                                        left join mst_equipment as meqad
                                                  on meqad.equipment_cd =
                                                     cast(ord.ind_cond_info -> ''6'' ->> ''value'' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select ''1次膜''                      as equip_class_type,
                                      meqpr.equipment_name         as equip_name,
                                      trim(meqpr.in_hospital_cd_1) as cd1,--1次膜コード１
                                      trim(meqpr.in_hospital_cd_2) as cd2,
                                      trim(meqpr.in_hospital_cd_3) as cd3,
                                      trim(meqpr.in_hospital_cd_4) as cd4,
                                      ''1''                          as amount,
                                      meqpr.unit,
                                      2                            as syoumouhinOrder
                               from ord_main as ord
                                        left join mst_equipment as meqpr
                                                  on meqpr.equipment_cd =
                                                     cast(ord.ind_cond_info -> ''7'' ->> ''value'' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select ''2次膜''                      as equip_class_type,
                                      meqse.equipment_name         as equip_name,
                                      trim(meqse.in_hospital_cd_1) as cd1,--2次膜コード１
                                      trim(meqse.in_hospital_cd_2) as cd2,
                                      trim(meqse.in_hospital_cd_3) as cd3,
                                      trim(meqse.in_hospital_cd_4) as cd4,
                                      ''1''                          as amount,
                                      meqse.unit,
                                      3                            as syoumouhinOrder
                               from ord_main as ord
                                        left join mst_equipment as meqse
                                                  on meqse.equipment_cd =
                                                     cast(ord.ind_cond_info -> ''8'' ->> ''value'' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select ''穿刺針A''                   as equip_class_type,
                                      meqa.equipment_name         as equip_name,
                                      trim(meqa.in_hospital_cd_1) as cd1,--穿刺針Aコード１
                                      trim(meqa.in_hospital_cd_2) as cd2,
                                      trim(meqa.in_hospital_cd_3) as cd3,
                                      trim(meqa.in_hospital_cd_4) as cd4,
                                      ''1''                         as amount,
                                      meqa.unit,
                                      4                           as syoumouhinOrder
                               from ord_main ord
                                        left join mst_equipment as meqa
                                                  on meqa.equipment_cd =
                                                     cast(ord.ind_cond_info -> ''9'' ->> ''value'' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select ''穿刺針V''                   as equip_class_type,
                                      meqv.equipment_name         as equip_name,
                                      trim(meqv.in_hospital_cd_1) as cd1,--穿刺針Vコード１
                                      trim(meqv.in_hospital_cd_2) as cd2,
                                      trim(meqv.in_hospital_cd_3) as cd3,
                                      trim(meqv.in_hospital_cd_4) as cd4,
                                      ''1''                         as amount,
                                      meqv.unit,
                                      4                           as syoumouhinOrder
                               from ord_main ord
                                        left join mst_equipment as meqv
                                                  on meqv.equipment_cd =
                                                     cast(ord.ind_cond_info -> ''10'' ->> ''value'' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select ''穿刺針SN''                   as equip_class_type,
                                      meqsn.equipment_name         as equip_name,
                                      trim(meqsn.in_hospital_cd_1) as cd1,--穿刺針SNコード１
                                      trim(meqsn.in_hospital_cd_2) as cd2,
                                      trim(meqsn.in_hospital_cd_3) as cd3,
                                      trim(meqsn.in_hospital_cd_4) as cd4,
                                      ''1''                          as amount,
                                      meqsn.unit,
                                      4                            as syoumouhinOrder
                               from ord_main ord
                                        left join mst_equipment as meqsn
                                                  on meqsn.equipment_cd =
                                                     cast(ord.ind_cond_info -> ''11'' ->> ''value'' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select ''血液回路''                   as equip_class_type,
                                      meqbc.equipment_name         as equip_name,
                                      trim(meqbc.in_hospital_cd_1) as cd1, --血液回路コード１
                                      trim(meqbc.in_hospital_cd_2) as cd2,
                                      trim(meqbc.in_hospital_cd_3) as cd3,
                                      trim(meqbc.in_hospital_cd_4) as cd4,
                                      ''1''                          as amount,
                                      meqbc.unit,
                                      5                            as syoumouhinOrder
                               from ord_main as ord
                                        left join mst_equipment as meqbc
                                                  on meqbc.equipment_cd =
                                                     cast(ord.ind_cond_info -> ''13'' ->> ''value'' as integer)
                               where ord.ord_no = @ordNo
                               union all
                               select meqc.class_name            as equip_class_type,
                                      meq.equipment_name         as equip_name,
                                      trim(meq.in_hospital_cd_1) as cd1,
                                      trim(meq.in_hospital_cd_2) as cd2,
                                      trim(meq.in_hospital_cd_3) as cd3,
                                      trim(meq.in_hospital_cd_4) as cd4,
                                      equip ->> ''amount''         as equip_amount,
                                      meq.unit                   as equip_unit,
                                      6                          as syoumouhinOrder
                               from ord_main as ord
                                        cross join lateral jsonb_array_elements(ord.ind_equip_info) equip
                                        left join mst_equipment as meq
                                                  on meq.equipment_cd = cast(equip ->> ''cd'' as integer)
                                        left join mst_equipment_class as meqc on meq.class_cd = meqc.class_cd
                               where ord.ord_no = @ordNo
                                 and equip ->> ''equip_type'' = ''0''
                               UNION ALL
                               SELECT ''ダイアライザ''       as equip_class_type,
                                      meq.model_number     as equip_name,
                                      meq.in_hospital_cd_1 AS cd1,
                                      meq.in_hospital_cd_2 AS cd2,
                                      meq.in_hospital_cd_3 AS cd3,
                                      meq.in_hospital_cd_4 AS cd4,
                                      equip ->> ''amount''   as equip_amount,
                                      equip ->> ''unit''     as equip_unit,
                                      25                   AS syoumouhinOrder
                               FROM ord_main ord
                                        CROSS JOIN LATERAL jsonb_array_elements(ord.ind_equip_info) equip
                                        LEFT JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = cast(equip ->> ''cd'' as integer)
                               WHERE equip ->> ''equip_type'' = ''1''
                                 AND ord.ord_no = @ordNo) all_equip
                         where all_equip.cd1 is not null)
   , do_data_group AS (select detail_id, cd1, name, amount, 
                              (case when max_order = 25 then max_order else min_order end) as syoumouhinOrder
                         from (SELECT detail_id
	                            , cd1
	                            , name
	                            , sum(amount)                       as amount
	                            , max(syoumouhinOrder) max_order, min(syoumouhinOrder) min_order
	                              FROM data_middle_all
	                            GROUP BY cd1, detail_id, name
                               ) as dma )
   , data_all AS (SELECT DISTINCT do_data_group.detail_id       AS detail_id,
                                  do_data_group.cd1             AS cd1,
                                  cd2,
                                  cd3,
                                  cd4,
                                  do_data_group.name            AS name,
                                  do_data_group.amount          AS amount,
                                  unit,
                                  do_data_group.syoumouhinOrder AS syoumouhinOrder
                  FROM do_data_group
                           LEFT JOIN data_middle_all ON data_middle_all.cd1 = do_data_group.cd1)
   , order_code_up_F AS (SELECT DISTINCT ON (e01f)*
                         FROM (SELECT meq.in_hospital_cd_1 AS e01f
                                    , CASE
                                          WHEN 1 in (SELECT ora FROM do_order_data_from)
                                              THEN cast(do_mstmeq_class_cd.meq_class_code_order as numeric)
                                 END                       AS cl_cd_f
                                    , CASE
                                          WHEN 2 in (SELECT ora FROM do_order_data_from)
                                              THEN cast(do_mstmeq_cd.meq_code_order as numeric)
                                 END                       AS eq_cd_f
                               FROM do_mstmeq_cd
                                        LEFT JOIN mst_equipment AS meq ON do_mstmeq_cd.meq_code = meq.equipment_cd
                                        LEFT JOIN do_mstmeq_class_cd ON do_mstmeq_class_cd.meq_class_code = meq.class_cd
                               WHERE meq.in_hospital_cd_1 IS NOT NULL
                               ORDER BY e01f asc) AS order_code_middle_F)
   , order_code_up_S AS (SELECT DISTINCT ON (e01s)*
                         FROM (SELECT CASE
                                          WHEN (SELECT in_hospital_cd_1
                                                FROM mst_equipment AS meq
                                                WHERE meq.equipment_cd = cast(equip ->> ''cd'' as integer)
                                                  AND meq.in_hospital_cd_1 IS NOT NULL) IS NULL
                                              THEN (SELECT in_hospital_cd_1
                                                    FROM mst_dialyzer AS dia
                                                    WHERE dia.dialyzer_cd = cast(equip ->> ''cd'' as integer)
                                                      AND dia.in_hospital_cd_1 IS NOT NULL)
                                          ELSE (SELECT in_hospital_cd_1
                                                FROM mst_equipment AS meq
                                                WHERE meq.equipment_cd = cast(equip ->> ''cd'' as integer)
                                                  AND meq.in_hospital_cd_1 IS NOT NULL) END AS e01s,
                                      CASE
                                          WHEN 0 in (SELECT ora FROM do_order_data_from)
                                              THEN TO_NUMBER(json_idx :: text, ''999999999999'')
                                          END                                               AS login_ord_s
                               FROM ord_main AS ord
                                        CROSS JOIN LATERAL
                                   jsonb_array_elements(ind_equip_info) with ordinality as tmp(equip, json_idx)
                               WHERE ord.ord_no = @ordNo
                               ORDER BY e01s, login_ord_s) AS order_code_middle_S)
   , do_data AS (SELECT detail_id
                      , cd1
                      , cd2
                      , cd3
                      , cd4
                      , name
                      , amount
                      , unit
                      , syoumouhinOrder
                      , (SELECT login_ord_s FROM order_code_up_S WHERE e01s = cd1)          AS login_ord
                      , CASE
                            WHEN (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) IS NULL THEN 0
                            ELSE (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) END AS cl_cd
                      , (SELECT eq_cd_f FROM order_code_up_F WHERE e01f = cd1)              AS eq_cd
                 FROM data_all)
SELECT detail_id,
       cd1,
       cd2,
       cd3,
       cd4,
       name,
       amount,
       unit,
       syoumouhinOrder,
       login_ord,
       cl_cd,
       eq_cd
FROM do_data
ORDER BY syoumouhinOrder,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END, cd1
limit 12',2,'[{}]','1','{"applications": [4]}',NULL,'指示）指示医材コード','2020-04-10 16:42:55.734',CURRENT_TIMESTAMP,NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES
(-191, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, do_mstmeq_cd AS (
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment'' 
)
, do_mstmeq_class_cd AS (
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment_class'' 
)
, do_ord AS (
SELECT * FROM ord_main_restore as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
ORDER BY del_date DESC LIMIT 1
)
, data_middle_all AS (
select 
 ''指示医材del'' as detail_id,
 row_number() over() as equip_no,
 all_equip.equip_class_type as class,
 all_equip.cd1 as cd1,
 all_equip.cd2 as cd2,
 all_equip.cd3 as cd3,
 all_equip.cd4 as cd4,
 all_equip.equip_name as name,
 ((COALESCE(all_equip.amount, ''0'')::FLOAT))::INTEGER as amount,
 all_equip.unit as unit,
 all_equip.syoumouhinOrder as syoumouhinOrder
from
(select
  ''吸着器'' as equip_class_type,
  --ord.ind_cond_info->''6''->>''value_name_1'' as name,
  meqad.equipment_name as equip_name,
  trim(meqad.in_hospital_cd_1) as cd1,--吸着器コード１
  trim(meqad.in_hospital_cd_2) as cd2,
  trim(meqad.in_hospital_cd_3) as cd3,
  trim(meqad.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqad.unit,
  1 as syoumouhinOrder
from
  ord_main as ord
left outer join
  mst_equipment as meqad
 on
  meqad.equipment_cd = TO_NUMBER (ord.ind_cond_info->''6''->>''value'',''999999999999'')
 where
  ord.ord_no =@ordNo

 union
 select
  ''1次膜'' as equip_class_type,
  --ord.ind_cond_info->''7''->>''value_name_1'' as primary_film,
  meqpr.equipment_name as equip_name,
  trim(meqpr.in_hospital_cd_1) as cd1,--1次膜コード１
  trim(meqpr.in_hospital_cd_2) as cd2,
  trim(meqpr.in_hospital_cd_3) as cd3,
  trim(meqpr.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqpr.unit,
    2 as syoumouhinOrder
 from
  ord_main as ord
  left outer join
  mst_equipment as meqpr
 on
  meqpr.equipment_cd = TO_NUMBER (ord.ind_cond_info->''7''->>''value'',''999999999999'')
  where
  ord.ord_no =@ordNo

 union
 select
  ''2次膜'' as equip_class_type,
  --ord.ind_cond_info->''8''->>''value_name_1'' as secondary_film,
  meqse.equipment_name as equip_name,
  trim(meqse.in_hospital_cd_1) as cd1,--2次膜コード１
  trim(meqse.in_hospital_cd_2) as cd2,
  trim(meqse.in_hospital_cd_3) as cd3,
  trim(meqse.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqse.unit,
    3 as syoumouhinOrder
  from
  ord_main as ord
  left outer join
  mst_equipment as meqse
 on
  meqse.equipment_cd = TO_NUMBER (ord.ind_cond_info->''8''->>''value'',''999999999999'')
  where
  ord.ord_no =@ordNo

 union
 select
  ''穿刺針A'' as equip_class_type,
  --ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  meqa.equipment_name as equip_name,
  trim(meqa.in_hospital_cd_1) as cd1,--穿刺針Aコード１
  trim(meqa.in_hospital_cd_2) as cd2,
  trim(meqa.in_hospital_cd_3) as cd3,
  trim(meqa.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqa.unit,
    4 as syoumouhinOrder
 from
  ord_main ord
   left outer join
   mst_equipment as meqa
  on
   meqa.equipment_cd = TO_NUMBER (ord.ind_cond_info->''9''->>''value'',''999999999999'')
   where
  ord.ord_no =@ordNo

 union
 select
  ''穿刺針V'' as equip_class_type,
  --ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  meqv.equipment_name as equip_name,
  trim(meqv.in_hospital_cd_1) as cd1,--穿刺針Vコード１
  trim(meqv.in_hospital_cd_2) as cd2,
  trim(meqv.in_hospital_cd_3) as cd3,
  trim(meqv.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqv.unit,
    4 as syoumouhinOrder
  from
  ord_main ord
   left outer join
   mst_equipment as meqv
  on
   meqv.equipment_cd = TO_NUMBER (ord.ind_cond_info->''10''->>''value'',''999999999999'')
   where
  ord.ord_no =@ordNo

 union
 select
  ''穿刺針SN'' as equip_class_type,
  --ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  meqsn.equipment_name as equip_name,
  trim(meqsn.in_hospital_cd_1) as cd1,--穿刺針SNコード１
  trim(meqsn.in_hospital_cd_2) as cd2,
  trim(meqsn.in_hospital_cd_3) as cd3,
  trim(meqsn.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqsn.unit,
    4 as syoumouhinOrder
 from
  ord_main ord
  left outer join
   mst_equipment as meqsn
  on
   meqsn.equipment_cd = TO_NUMBER (ord.ind_cond_info->''11''->>''value'',''999999999999'')
 where
  ord.ord_no =@ordNo

 union
 select
  ''血液回路'' as equip_class_type,
  --ord.ind_cond_info->''13''->>''value'' as blood_circuit,
  meqbc.equipment_name as equip_name,
  trim(meqbc.in_hospital_cd_1) as cd1, --血液回路コード１
  trim(meqbc.in_hospital_cd_2) as cd2,
  trim(meqbc.in_hospital_cd_3) as cd3,
  trim(meqbc.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqbc.unit,
    5 as syoumouhinOrder
from
  ord_main as ord
 left outer join
  mst_equipment as meqbc
 on
  meqbc.equipment_cd = TO_NUMBER (ord.ind_cond_info->''13''->>''value'',''999999999999'')
where
 ord.ord_no =@ordNo

union
select
   --equip ->> ''class_type'' as equip_class_type,
   --equip ->> ''name'' as equip_name,
   meqc.class_name  as equip_class_type,
   meq.equipment_name as equip_name,
   trim(meq.in_hospital_cd_1) as cd1,
   trim(meq.in_hospital_cd_2) as cd2,
   trim(meq.in_hospital_cd_3) as cd3,
   trim(meq.in_hospital_cd_4) as cd4,
   equip ->> ''amount'' as equip_amount,
   meq.unit as equip_unit,
     6 as syoumouhinOrder
from
        ord_main as ord
    cross join lateral
        json_array_elements (ord.ind_equip_info :: json) equip
     left outer join
         mst_equipment as meq
     on
         meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
     left join mst_equipment_class as meqc
     on meq.class_cd = meqc.class_cd
    where
        --meq.class_cd = meqc.class_cd and
        ord.ord_no =@ordNo
				and equip ->> ''equip_type'' = ''0''
						UNION ALL
  SELECT--医材情報
    ''ダイアライザ'' as equip_class_type,
		meq.model_number as equip_name,
    meq.in_hospital_cd_1 AS cd1,
		meq.in_hospital_cd_2 AS cd2,
		meq.in_hospital_cd_3 AS cd3,
		meq.in_hospital_cd_4 AS cd4,
		equip ->> ''amount'' as equip_amount,
    equip ->> ''unit'' as equip_unit,
    25 AS syoumouhinOrder
  FROM
   ord_main as ord
    CROSS JOIN LATERAL json_array_elements ( ord.ind_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
    and ord.ord_no =@ordNo
				
) all_equip
where
 all_equip.cd1 is not null
union all
 (select 
 ''指示医材del'' as detail_id,
 row_number() over() as equip_no,
 all_equip.equip_class_type as class,
 all_equip.cd1 as cd1,
 all_equip.cd2 as cd2,
 all_equip.cd3 as cd3,
 all_equip.cd4 as cd4,
 all_equip.equip_name as name,
 ((COALESCE(all_equip.amount, ''0'')::FLOAT))::INTEGER as amount,
 all_equip.unit as unit,
 all_equip.syoumouhinOrder as syoumouhinOrder
from
(select
  ''吸着器'' as equip_class_type,
  --ord.ind_cond_info->''6''->>''value_name_1'' as name,
  meqad.equipment_name as equip_name,
  trim(meqad.in_hospital_cd_1) as cd1,--吸着器コード１
  trim(meqad.in_hospital_cd_2) as cd2,
  trim(meqad.in_hospital_cd_3) as cd3,
  trim(meqad.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqad.unit,
    1 as syoumouhinOrder
from
  --ord_main_restore as ord
    do_ord as ord
left outer join
  mst_equipment as meqad
 on
  meqad.equipment_cd = TO_NUMBER (ord.ind_cond_info->''6''->>''value'',''999999999999'')
 where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''1次膜'' as equip_class_type,
  --ord.ind_cond_info->''7''->>''value_name_1'' as primary_film,
  meqpr.equipment_name as equip_name,
  trim(meqpr.in_hospital_cd_1) as cd1,--1次膜コード１
  trim(meqpr.in_hospital_cd_2) as cd2,
  trim(meqpr.in_hospital_cd_3) as cd3,
  trim(meqpr.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqpr.unit,
    2 as syoumouhinOrder
 from
  --ord_main_restore as ord
    do_ord as ord
  left outer join
  mst_equipment as meqpr
 on
  meqpr.equipment_cd = TO_NUMBER (ord.ind_cond_info->''7''->>''value'',''999999999999'')
  where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''2次膜'' as equip_class_type,
  --ord.ind_cond_info->''8''->>''value_name_1'' as secondary_film,
  meqse.equipment_name as equip_name,
  trim(meqse.in_hospital_cd_1) as cd1,--2次膜コード１
  trim(meqse.in_hospital_cd_2) as cd2,
  trim(meqse.in_hospital_cd_3) as cd3,
  trim(meqse.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqse.unit,
    3 as syoumouhinOrder
  from
  --ord_main_restore as ord
    do_ord as ord
  left outer join
  mst_equipment as meqse
 on
  meqse.equipment_cd = TO_NUMBER (ord.ind_cond_info->''8''->>''value'',''999999999999'')
  where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''穿刺針A'' as equip_class_type,
  --ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  meqa.equipment_name as equip_name,
  trim(meqa.in_hospital_cd_1) as cd1,--穿刺針Aコード１
  trim(meqa.in_hospital_cd_2) as cd2,
  trim(meqa.in_hospital_cd_3) as cd3,
  trim(meqa.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqa.unit,
    4 as syoumouhinOrder
 from
  --ord_main_restore as ord
    do_ord as ord
   left outer join
   mst_equipment as meqa
  on
   meqa.equipment_cd = TO_NUMBER (ord.ind_cond_info->''9''->>''value'',''999999999999'')
   where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''穿刺針V'' as equip_class_type,
  --ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  meqv.equipment_name as equip_name,
  trim(meqv.in_hospital_cd_1) as cd1,--穿刺針Vコード１
  trim(meqv.in_hospital_cd_2) as cd2,
  trim(meqv.in_hospital_cd_3) as cd3,
  trim(meqv.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqv.unit,
    4 as syoumouhinOrder
  from
  --ord_main_restore as ord
    do_ord as ord
   left outer join
   mst_equipment as meqv
  on
   meqv.equipment_cd = TO_NUMBER (ord.ind_cond_info->''10''->>''value'',''999999999999'')
   where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''穿刺針SN'' as equip_class_type,
  --ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  meqsn.equipment_name as equip_name,
  trim(meqsn.in_hospital_cd_1) as cd1,--穿刺針SNコード１
  trim(meqsn.in_hospital_cd_2) as cd2,
  trim(meqsn.in_hospital_cd_3) as cd3,
  trim(meqsn.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqsn.unit,
    4 as syoumouhinOrder
   from
  --ord_main_restore as ord
    do_ord as ord
  left outer join
   mst_equipment as meqsn
  on
   meqsn.equipment_cd = TO_NUMBER (ord.ind_cond_info->''11''->>''value'',''999999999999'')
 where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''血液回路'' as equip_class_type,
  --ord.ind_cond_info->''13''->>''value'' as blood_circuit,
  meqbc.equipment_name as equip_name,
  trim(meqbc.in_hospital_cd_1) as cd1, --血液回路コード１
  trim(meqbc.in_hospital_cd_2) as cd2,
  trim(meqbc.in_hospital_cd_3) as cd3,
  trim(meqbc.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqbc.unit,
    5 as syoumouhinOrder
from
  --ord_main_restore as ord
    do_ord as ord
 left outer join
  mst_equipment as meqbc
 on
  meqbc.equipment_cd = TO_NUMBER (ord.ind_cond_info->''13''->>''value'',''999999999999'')
where
 ord.ord_no =@ordNo
 and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
union
select
   --equip ->> ''class_type'' as equip_class_type,
   --equip ->> ''name'' as equip_name,
   meqc.class_name  as equip_class_type,
   meq.equipment_name as equip_name,
   trim(meq.in_hospital_cd_1) as cd1,
   trim(meq.in_hospital_cd_2) as cd2,
   trim(meq.in_hospital_cd_3) as cd3,
   trim(meq.in_hospital_cd_4) as cd4,
   equip ->> ''amount'' as equip_amount,
   meq.unit as equip_unit,
     6 as syoumouhinOrder
from
        --ord_main_restore as ord
    do_ord as ord
    cross join lateral
        json_array_elements (ord.ind_equip_info :: json) equip
     left outer join
         mst_equipment as meq
     on
         meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
     left join mst_equipment_class as meqc
     on meq.class_cd = meqc.class_cd
    where
        --meq.class_cd = meqc.class_cd and
        ord.ord_no =@ordNo
				and equip ->> ''equip_type'' = ''0''
        and ''0'' =(
        select count(*) from ord_main where ord_no =@ordNo)
			UNION ALL
  SELECT--医材情報
    ''ダイアライザ'' as equip_class_type,
		meq.model_number as equip_name,
    meq.in_hospital_cd_1 AS cd1,
		meq.in_hospital_cd_2 AS cd2,
		meq.in_hospital_cd_3 AS cd3,
		meq.in_hospital_cd_4 AS cd4,
		equip ->> ''amount'' as equip_amount,
    equip ->> ''unit'' as equip_unit,
    25 AS syoumouhinOrder
  FROM
   do_ord as ord
    CROSS JOIN LATERAL json_array_elements ( ord.ind_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
    and ord.ord_no =@ordNo
    and ''0'' =(
        select count(*) from ord_main where ord_no =@ordNo)
) all_equip
where
 all_equip.cd1 is not null)
 )
, do_data_group AS (
select detail_id, cd1, name, amount, 
        (case when max_order = 25 then max_order else min_order end) as syoumouhinOrder
  from (SELECT detail_id
	         , cd1
	         , name
	         , sum(amount) as amount
	         , max(syoumouhinOrder) max_order, min(syoumouhinOrder) min_order
	      FROM data_middle_all
	    GROUP BY cd1, detail_id, name
  ) as dma
)
, data_all AS (
 SELECT DISTINCT do_data_group.detail_id AS detail_id, do_data_group.cd1 AS cd1, cd2, cd3, cd4, do_data_group.name AS name, do_data_group.amount AS amount, unit, 
        do_data_group.syoumouhinOrder AS syoumouhinOrder
 FROM do_data_group
      LEFT JOIN data_middle_all ON data_middle_all.cd1 = do_data_group.cd1
)
, order_code_up_F AS (
SELECT DISTINCT ON (e01f)* FROM (
  SELECT 
    meq.in_hospital_cd_1 AS e01f
    , CASE WHEN 1 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_class_cd.meq_class_code_order :: text, ''999999999999'') ELSE NULL END AS cl_cd_f
    , CASE WHEN 2 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_cd.meq_code_order :: text, ''999999999999'') ELSE NULL END AS eq_cd_f
  FROM
    do_mstmeq_cd
    LEFT JOIN mst_equipment AS meq ON do_mstmeq_cd.meq_code = meq.equipment_cd
    LEFT JOIN do_mstmeq_class_cd ON do_mstmeq_class_cd.meq_class_code = meq.class_cd
  WHERE meq.in_hospital_cd_1 IS NOT NULL
  ORDER BY e01f asc) AS order_code_middle_F
)
, order_code_up_S AS (
SELECT DISTINCT ON (e01s)* FROM (
  SELECT 
    CASE WHEN (SELECT in_hospital_cd_1 FROM mst_equipment AS meq 
                   WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND meq.in_hospital_cd_1 IS NOT NULL) IS NULL
         THEN (SELECT in_hospital_cd_1 FROM mst_dialyzer AS dia 
                   WHERE dia.dialyzer_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND dia.in_hospital_cd_1 IS NOT NULL)
         ELSE (SELECT in_hospital_cd_1 FROM mst_equipment AS meq 
                   WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND meq.in_hospital_cd_1 IS NOT NULL) END AS e01s,
    CASE WHEN 0 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(json_idx :: text, ''999999999999'') ELSE NULL END AS login_ord_s
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(equip, json_idx)
  WHERE
    ord.ord_no = @ordNo
  ORDER BY e01s, login_ord_s asc) AS order_code_middle_S
	union 
	(
	SELECT DISTINCT ON (e01s)* FROM (
  SELECT 
    CASE WHEN (SELECT in_hospital_cd_1 FROM mst_equipment AS meq 
                   WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND meq.in_hospital_cd_1 IS NOT NULL) IS NULL
         THEN (SELECT in_hospital_cd_1 FROM mst_dialyzer AS dia 
                   WHERE dia.dialyzer_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND dia.in_hospital_cd_1 IS NOT NULL)
         ELSE (SELECT in_hospital_cd_1 FROM mst_equipment AS meq 
                   WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND meq.in_hospital_cd_1 IS NOT NULL) END AS e01s,
    CASE WHEN 0 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(json_idx :: text, ''999999999999'') ELSE NULL END AS login_ord_s
  FROM
    do_ord AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(equip, json_idx)
		where ''0'' =(
        select count(*) from ord_main where ord_no = @ordNo )
  ORDER BY e01s, login_ord_s asc) AS order_code_middle_S
	)
)
, do_data AS (
SELECT detail_id, cd1, cd2, cd3, cd4, name, amount, unit, syoumouhinOrder
    , (SELECT login_ord_s FROM order_code_up_S WHERE e01s = cd1) AS login_ord
        , CASE WHEN (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) IS NULL THEN 0 ELSE (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) END AS cl_cd
    , (SELECT eq_cd_f FROM order_code_up_F WHERE e01f = cd1) AS eq_cd
FROM  data_all
)
SELECT detail_id, cd1, cd2, cd3, cd4, name, amount, unit, syoumouhinOrder, login_ord, cl_cd, eq_cd
FROM do_data
ORDER BY syoumouhinOrder,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END, cd1
limit 12',2,'[{}]','1','{"applications": [4]}',NULL,'指示)中止時）指示医材1コード','2022-06-18 05:06:30.633',CURRENT_TIMESTAMP,NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES
(-498, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
), EQUIP_OUTPUT_TYPE_cd AS 
(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE''),
do_mstmeq_cd AS (
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment'' 
)
, do_mstmeq_class_cd AS (
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment_class'' 
)
, data_all AS (
SELECT
  ''医材'' AS detail_id,
  TRIM (all_cost.e01) AS item_cd,
  all_cost.e02 AS name,
  all_cost.e03 AS type_name,
  all_cost.e04 AS class_name,
  COALESCE(all_cost.e05, ''0'') ::Float AS amount,
	COALESCE(all_cost.e05, ''0'') ::Float AS amounttest,
  COALESCE(all_cost.e06, '''') AS unit,
  all_cost.syoumouhinOrder AS syoumouhinOrder
FROM
  (
    SELECT--血液回路情報
    ''血液回路'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''血液回路'' AS e03,
    ''0'' AS e04,
		  (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05, 
    meq.unit AS e06,
    11 AS syoumouhinOrder
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
  UNION ALL
    SELECT--A針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''A針'' AS e03,
    ''1'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    8 AS syoumouhinOrder
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
  UNION ALL
    SELECT--V針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''V針'' AS e03,
    ''2'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    9 AS syoumouhinOrder
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
  UNION ALL
    SELECT--SN針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''SN針'' AS e03,
    ''3'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    10 AS syoumouhinOrder
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
  UNION ALL
    SELECT--医材内穿刺針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''穿刺針'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			 ((equip ->> ''amount'')::INTEGER*100)::text
			else 
        equip ->> ''amount'' 
      END) AS e05,
    equip ->> ''unit'' AS e06,
    12 AS syoumouhinOrder
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''class_type'' IN ( ''2'', ''3'' )
    AND ord.ord_no = @ordNo
  UNION ALL
    SELECT--医材情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''医材'' AS e03,
    ''0'' AS e04,
    (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			 ((equip ->> ''amount'')::INTEGER*100)::text
			else 
        equip ->> ''amount'' 
      END) AS e05,
    equip ->> ''unit'' AS e6,
    12 AS syoumouhinOrder
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''0''
    AND (equip ->> ''class_type'' NOT IN (''2'', ''3'') or equip ->>''class_type'' is null)
    AND ord.ord_no = @ordNo
  UNION ALL
    SELECT--医材情報
    ''ダイアライザ'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.model_number AS e02,
    ''ダイアライザ'' AS e03,
    ''0'' AS e04,
		 (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			 ((equip ->> ''amount'')::INTEGER*100)::text
			else 
        equip ->> ''amount'' 
      END) AS e05,
    equip ->> ''unit'' AS e6,
    25 AS syoumouhinOrder
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
    AND ord.ord_no = @ordNo
  UNION ALL
  SELECT--医材情報
    ''加算・管理料'' AS detail_id,
    adt.in_hospital_cd_1 AS e01,
    adt.addition_name AS e02,
    ''加算・管理料'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    '''' AS e6,
    1 AS syoumouhinOrder
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addition
    LEFT OUTER JOIN mst_addition AS adt ON adt.addition_cd = TO_NUMBER( addition ->> ''cd'', ''999999999999'' )
  WHERE
    addition ->> ''is_enable'' = ''1''
    AND ord.ord_no = @ordNo
  UNION ALL
    SELECT--1次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    6 AS syoumouhinOrder
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
    and ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  UNION ALL
    SELECT--2次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    7 AS syoumouhinOrder
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
    AND ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  UNION ALL
    SELECT--吸着カラム情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    5 AS syoumouhinOrder
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
    ord.ord_no = @ordNo
    AND ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
),
data_all_weight AS (
SELECT
  ''医材'' AS detail_id,
  TRIM (all_cost_weight.e01) AS item_cd,
  all_cost_weight.e02 AS name,
  all_cost_weight.e03 AS type_name,
  all_cost_weight.e04 AS class_name,
  COALESCE(all_cost_weight.e05, ''0'') ::Float AS amount,
	COALESCE(all_cost_weight.e05, ''0'') ::text AS amounttest,
  COALESCE(all_cost_weight.e06, '''') AS unit,
  all_cost_weight.syoumouhinOrder AS syoumouhinOrder
FROM
  (
 select --目標体重出力
	''医材'' AS detail_id,
	(SELECT
    (info ->> ''value'') 
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''TARGET_WEIGHT_CD'') as e01,
	NULL AS  e02,
	NULL AS e03,
	NULL AS  e04,
-- 	(COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'') :: FLOAT * 100)::text AS e05,
(CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')  and (COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT)*100<100  THEN 
		 (case when (COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT)*100 >10 
        then ''0''||((COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT *100)::TEXT) 
        else  ''00''||((COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT*100)::TEXT)
         end) 
			else 
			((COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'') :: FLOAT * 100):: INTEGER)::text
      END) AS e05,
	''kg'' AS  e06,
	4 AS syoumouhinOrder
   from ord_main where ord_no =@ordNo
	 and rst_cond_info-> ''3'' ->> ''value'' is not NULL
	 AND rst_cond_info-> ''3'' ->> ''value'' !=''0''
	 AND  (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''TARGET_WEIGHT_CD'') IS NOT NULL
		and (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''TARGET_WEIGHT_CD'')!= ''''
		 union All
 select --前体重出力
	''医材'' AS detail_id,
(SELECT
    (info ->> ''value'') 
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''BEFORE_WEIGHT_CD'') as e01,
	NULL AS  e02,
	NULL AS e03,
	NULL AS  e04,
-- 	 (COALESCE(rst_weight_info ->> ''weight_before'', ''0'') :: FLOAT * 100)::text AS e05,
 (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and (COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT)*100<100  THEN 
		 (case when (COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT)*100 >10 
        then ''0''||((COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT *100)::TEXT) 
        else  ''00''||((COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT*100)::TEXT)
         end) 
			else 
			((COALESCE(rst_weight_info ->> ''weight_before'', ''0'') :: FLOAT * 100):: INTEGER)::text
      END) AS e05,
	''kg'' AS  e06,
    2 AS syoumouhinOrder
   from ord_main where ord_no =@ordNo
	 and rst_weight_info ->> ''weight_before'' is not NULL
	 AND rst_weight_info ->> ''weight_before'' !=''0''
	 AND  (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''BEFORE_WEIGHT_CD'') IS NOT NULL
		and (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''BEFORE_WEIGHT_CD'')!= ''''
	union All
  select --後体重出力
	''医材'' AS detail_id,
  (SELECT (info ->> ''value'') 
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''AFTER_WEIGHT_CD'') as e01,
	NULL AS  e02,
	NULL AS e03,
	NULL AS  e04,
	 (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and (COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT)*100<100  THEN 
		 (case when (COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT)*100 >10 
        then ''0''||((COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT *100)::TEXT) 
        else  ''00''||((COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT*100)::TEXT)
         end) 
			else 
			((COALESCE(rst_weight_info ->> ''weight_after'', ''0'') :: FLOAT * 100):: INTEGER)::text
      END) AS e05,
	''kg'' AS  e06,
    3 AS syoumouhinOrder
   from ord_main where ord_no = @ordNo
	 and rst_weight_info ->> ''weight_after'' is not NULL
	 AND rst_weight_info ->> ''weight_after'' !=''0''
	 AND  (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''AFTER_WEIGHT_CD'') IS NOT NULL
		and (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
	AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''AFTER_WEIGHT_CD'')!= ''''
)all_cost_weight
WHERE
  all_cost_weight.e01 IS NOT NULL)
, do_data_group AS (
select detail_id, item_cd, name,  amounttest, (case when max_order = 25 then max_order else min_order end) as syoumouhinOrder 
from (
	SELECT 
	    (detail_id:: text) AS detail_id, LEFT(item_cd, 8) AS item_cd, name, SUM(amounttest)::text AS amounttest
	    ,max(syoumouhinOrder) max_order, min(syoumouhinOrder) min_order
	FROM  
	    data_all
	GROUP BY item_cd, detail_id :: text, name
) as dal
union all
SELECT 
    (detail_id:: text) AS detail_id, LEFT(item_cd, 8) AS item_cd, name, amounttest
    , CASE WHEN SUM(syoumouhinOrder) > 12 THEN SUM(syoumouhinOrder) - 12 ELSE SUM(syoumouhinOrder) END AS syoumouhinOrder
FROM  
    data_all_weight
GROUP BY item_cd, detail_id :: text, name,amounttest
)
, order_code_up_F AS (
SELECT DISTINCT ON (e01f)* FROM (
  SELECT 
    LEFT(meq.in_hospital_cd_1, 8) AS e01f
    , CASE WHEN 1 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_class_cd.meq_class_code_order :: text, ''999999999999'') ELSE NULL END AS cl_cd_f
    , CASE WHEN 2 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_cd.meq_code_order :: text, ''999999999999'') ELSE NULL END AS eq_cd_f
  FROM
    do_mstmeq_cd
    LEFT JOIN mst_equipment AS meq ON do_mstmeq_cd.meq_code = meq.equipment_cd
    LEFT JOIN do_mstmeq_class_cd ON do_mstmeq_class_cd.meq_class_code = meq.class_cd
  WHERE meq.in_hospital_cd_1 IS NOT NULL
  ORDER BY e01f asc) AS order_code_middle_F
)
, order_code_up_S AS (
SELECT DISTINCT ON (e01s)* FROM (
  SELECT 
    CASE WHEN (SELECT LEFT(in_hospital_cd_1, 8) FROM mst_equipment AS meq 
                 WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                   AND meq.in_hospital_cd_1 IS NOT NULL) IS NULL
         THEN (SELECT LEFT(in_hospital_cd_1, 8) FROM mst_dialyzer AS dia 
                 WHERE dia.dialyzer_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                   AND dia.in_hospital_cd_1 IS NOT NULL)
         ELSE (SELECT LEFT(in_hospital_cd_1, 8) FROM mst_equipment AS meq 
                 WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                   AND meq.in_hospital_cd_1 IS NOT NULL) END AS e01s,
    CASE WHEN 0 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(json_idx :: text, ''999999999999'') ELSE NULL END AS login_ord_s
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info :: json) with ordinality as tmp(equip, json_idx)
  WHERE ord.ord_no = @ordNo
  ORDER BY e01s, login_ord_s asc) AS order_code_middle_S
)
, dia_data_order AS (
SELECT DISTINCT item_cd, CASE type_name WHEN ''ダイアライザ'' THEN 
    (SELECT dialyzer_cd FROM mst_dialyzer WHERE item_cd = in_hospital_cd_1 AND mst_dialyzer.facility_cd = @facilityCd) ELSE 0 END AS dia_cd
FROM data_all
)
, do_data AS (
SELECT detail_id, item_cd, name, amounttest, syoumouhinOrder
    , (SELECT login_ord_s FROM order_code_up_S WHERE e01s = item_cd) AS login_ord
		, CASE WHEN (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = item_cd) IS NULL THEN 0 ELSE (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = item_cd) END AS cl_cd
    , (SELECT eq_cd_f FROM order_code_up_F WHERE e01f = item_cd) AS eq_cd
    , (SELECT dia_cd FROM dia_data_order WHERE dia_data_order.item_cd = do_data_group.item_cd) AS dia_cd
FROM  do_data_group
)
SELECT detail_id, item_cd, name, amounttest, syoumouhinOrder, login_ord, cl_cd, eq_cd, dia_cd
FROM do_data
ORDER BY syoumouhinOrder,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END, dia_cd, item_cd
limit (SELECT
    (case WHEN (COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''))=''0'' THEN 10 ELSE 108 END) AS staff_cd
     FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
     WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
				AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
        AND info ->> ''key1'' = ''DIALYSISSEND''
        AND info ->> ''key2'' = ''EQUIP_OUTPUT'')',2,'[{}]','1','{"applications": [4]}',NULL,'日機装)実績）医材繰り返し部','2020-05-22 11:43:49.001',CURRENT_TIMESTAMP,NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES
(-504, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
), 
ord_main_do as (
  (SELECT
    ord.del_date as up_date_switch,
    ord.rst_cond_info AS rst_cond_info,
    ord.rst_equip_info AS rst_equip_info,
    ord.addition_info AS addition_info,
    ord.rst_weight_info AS rst_weight_info
  FROM ord_main_restore as ord
  JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
  WHERE ord.ord_no = @ordNo
    AND journal.ctl_no = @ctlNo
    AND ord.ord_no = journal.ord_no
    AND journal.reg_date >= ord.del_date
  ORDER BY ord.del_date DESC LIMIT 1)
UNION
  (SELECT
    ord.rst_edition_date as up_date_switch,
    ord.rst_cond_info AS rst_cond_info,
    ord.rst_equip_info AS rst_equip_info,
    ord.addition_info AS addition_info,
    ord.rst_weight_info AS rst_weight_info
  FROM ord_main AS ord
  WHERE ord.ord_no = @ordNo)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
),
EQUIP_OUTPUT_TYPE_cd AS 
(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''EQUIP_OUTPUT_TYPE''),
do_mstmeq_cd AS (
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment'' 
)
, do_mstmeq_class_cd AS (
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment_class'' 
)
, data_all AS (
SELECT
  ''医材del'' AS detail_id,
  TRIM (all_cost.e01) AS item_cd,
  all_cost.e02 AS name,
  all_cost.e03 AS type_name,
  all_cost.e04 AS class_name,
  COALESCE(all_cost.e05, ''0'') ::Float AS amount,
	COALESCE(all_cost.e05, ''0'') ::Float AS amounttest,
  COALESCE(all_cost.e06, '''') AS unit,
  all_cost.syoumouhinOrder AS syoumouhinOrder
FROM
  (
    SELECT--血液回路情報
    ''血液回路'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''血液回路'' AS e03,
    ''0'' AS e04,
		  (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05, 
    meq.unit AS e06,
    11 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''999999999999'' )
  UNION ALL
    SELECT--A針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''A針'' AS e03,
    ''1'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    8 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''999999999999'' )
  UNION ALL
    SELECT--V針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''V針'' AS e03,
    ''2'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    9 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''999999999999'' )
  UNION ALL
    SELECT--SN針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''SN針'' AS e03,
    ''3'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    10 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''999999999999'' )
  UNION ALL
    SELECT--医材内穿刺針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''穿刺針'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			 ((equip ->> ''amount'')::INTEGER*100)::text
			else 
        equip ->> ''amount'' 
      END) AS e05,
    equip ->> ''unit'' AS e06,
    12 AS syoumouhinOrder
  FROM
    ord_main_do ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''class_type'' IN ( ''2'', ''3'' )
  UNION ALL
    SELECT--医材情報
    ''医材del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''医材'' AS e03,
    ''0'' AS e04,
    (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			 ((equip ->> ''amount'')::INTEGER*100)::text
			else 
        equip ->> ''amount'' 
      END) AS e05,
    equip ->> ''unit'' AS e6,
    12 AS syoumouhinOrder
  FROM
    ord_main_do ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''0''
    AND (equip ->> ''class_type'' NOT IN (''2'', ''3'') or equip ->>''class_type'' is null)
  UNION ALL
    SELECT--医材情報
    ''ダイアライザ'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.model_number AS e02,
    ''ダイアライザ'' AS e03,
    ''0'' AS e04,
		 (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			 ((equip ->> ''amount'')::INTEGER*100)::text
			else 
        equip ->> ''amount'' 
      END) AS e05,
    equip ->> ''unit'' AS e6,
    25 AS syoumouhinOrder
  FROM
    ord_main_do ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
  UNION ALL
  SELECT--医材情報
    ''加算・管理料'' AS detail_id,
    adt.in_hospital_cd_1 AS e01,
    adt.addition_name AS e02,
    ''加算・管理料'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    '''' AS e6,
    1 AS syoumouhinOrder
  FROM
    ord_main_do ord
    CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addition
    LEFT OUTER JOIN mst_addition AS adt ON adt.addition_cd = TO_NUMBER( addition ->> ''cd'', ''999999999999'' )
  WHERE
    addition ->> ''is_enable'' = ''1''
  UNION ALL
    SELECT--1次膜情報
    ''医材del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    6 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  WHERE
   ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  UNION ALL
    SELECT--2次膜情報
    ''医材del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    7 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  WHERE
  ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  UNION ALL
    SELECT--吸着カラム情報
    ''医材del'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''0'' AS e04,
     (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CONTROLHUNDRED'') THEN 
			''100''
			else 
        ''1'' 
      END) AS e05,
    meq.unit AS e06,
    5 AS syoumouhinOrder
  FROM
    ord_main_do ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  WHERE
   ''0''=(SELECT case when (select staff_cd from EQUIP_OUTPUT_TYPE_cd) IS NULL or 
			(select staff_cd from EQUIP_OUTPUT_TYPE_cd) = ''''
			then  ''0'' else (select staff_cd from EQUIP_OUTPUT_TYPE_cd)
			END)
  ) all_cost
WHERE
  all_cost.e01 IS NOT NULL
),
data_all_weight AS (
SELECT
  ''医材del'' AS detail_id,
  TRIM (all_cost_weight.e01) AS item_cd,
  all_cost_weight.e02 AS name,
  all_cost_weight.e03 AS type_name,
  all_cost_weight.e04 AS class_name,
  COALESCE(all_cost_weight.e05, ''0'') ::Float AS amount,
	COALESCE(all_cost_weight.e05, ''0'') ::text AS amounttest,
  COALESCE(all_cost_weight.e06, '''') AS unit,
  all_cost_weight.syoumouhinOrder AS syoumouhinOrder
FROM
  (
 select --目標体重出力
	''医材del'' AS detail_id,
	(SELECT
    (info ->> ''value'') 
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''TARGET_WEIGHT_CD'') as e01,
	NULL AS  e02,
	NULL AS e03,
	NULL AS  e04,
-- 	(COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'') :: FLOAT * 100)::text AS e05,
(CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')  and (COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT)*100<100  THEN 
		 (case when (COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT)*100 >10 
        then ''0''||((COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT *100)::TEXT) 
        else  ''00''||((COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'')::FLOAT*100)::TEXT)
         end) 
			else 
			((COALESCE(rst_cond_info-> ''3'' ->> ''value'', ''0'') :: FLOAT * 100):: INTEGER)::text
      END) AS e05,
	''kg'' AS  e06,
	4 AS syoumouhinOrder
   from ord_main_do
	 where rst_cond_info-> ''3'' ->> ''value'' is not NULL
	 AND rst_cond_info-> ''3'' ->> ''value'' !=''0''
	 AND  (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''TARGET_WEIGHT_CD'') IS NOT NULL
		and (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''TARGET_WEIGHT_CD'')!= ''''
		 union All
 select --前体重出力
	''医材del'' AS detail_id,
(SELECT
    (info ->> ''value'') 
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''BEFORE_WEIGHT_CD'') as e01,
	NULL AS  e02,
	NULL AS e03,
	NULL AS  e04,
-- 	 (COALESCE(rst_weight_info ->> ''weight_before'', ''0'') :: FLOAT * 100)::text AS e05,
 (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and (COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT)*100<100  THEN 
		 (case when (COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT)*100 >10 
        then ''0''||((COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT *100)::TEXT) 
        else  ''00''||((COALESCE(rst_weight_info ->> ''weight_before'', ''0'')::FLOAT*100)::TEXT)
         end) 
			else 
			((COALESCE(rst_weight_info ->> ''weight_before'', ''0'') :: FLOAT * 100):: INTEGER)::text
      END) AS e05,
	''kg'' AS  e06,
    2 AS syoumouhinOrder
   from ord_main_do
	 where rst_weight_info ->> ''weight_before'' is not NULL
	 AND rst_weight_info ->> ''weight_before'' !=''0''
	 AND  (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''BEFORE_WEIGHT_CD'') IS NOT NULL
		and (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''BEFORE_WEIGHT_CD'')!= ''''
	union All
  select --後体重出力
	''医材del'' AS detail_id,
  (SELECT (info ->> ''value'') 
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''AFTER_WEIGHT_CD'') as e01,
	NULL AS  e02,
	NULL AS e03,
	NULL AS  e04,
	 (CASE WHEN ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and (COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT)*100<100  THEN 
		 (case when (COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT)*100 >10 
        then ''0''||((COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT *100)::TEXT) 
        else  ''00''||((COALESCE(rst_weight_info ->> ''weight_after'', ''0'')::FLOAT*100)::TEXT)
         end) 
			else 
			((COALESCE(rst_weight_info ->> ''weight_after'', ''0'') :: FLOAT * 100):: INTEGER)::text
      END) AS e05,
	''kg'' AS  e06,
    3 AS syoumouhinOrder
   from ord_main_do
	 where rst_weight_info ->> ''weight_after'' is not NULL
	 AND rst_weight_info ->> ''weight_after'' !=''0''
	 AND  (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
		AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''AFTER_WEIGHT_CD'') IS NOT NULL
		and (SELECT
    (info ->> ''value'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
	AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''AFTER_WEIGHT_CD'')!= ''''
)all_cost_weight
WHERE
  all_cost_weight.e01 IS NOT NULL)
, do_data_group AS (
select detail_id, item_cd, name,  amounttest, (case when max_order = 25 then max_order else min_order end) as syoumouhinOrder 
from (
	SELECT 
	    (detail_id:: text) AS detail_id, LEFT(item_cd, 8) AS item_cd, name, SUM(amounttest)::text AS amounttest
	    ,max(syoumouhinOrder) max_order, min(syoumouhinOrder) min_order
	FROM  
	    data_all
	GROUP BY item_cd, detail_id :: text, name
) as dal
union all
SELECT 
    (detail_id:: text) AS detail_id, LEFT(item_cd, 8) AS item_cd, name, amounttest
    , CASE WHEN SUM(syoumouhinOrder) > 12 THEN SUM(syoumouhinOrder) - 12 ELSE SUM(syoumouhinOrder) END AS syoumouhinOrder
FROM  
    data_all_weight
GROUP BY item_cd, detail_id :: text, name,amounttest
)
, order_code_up_F AS (
SELECT DISTINCT ON (e01f)* FROM (
  SELECT 
    LEFT(meq.in_hospital_cd_1, 8) AS e01f
    , CASE WHEN 1 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_class_cd.meq_class_code_order :: text, ''999999999999'') ELSE NULL END AS cl_cd_f
    , CASE WHEN 2 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_cd.meq_code_order :: text, ''999999999999'') ELSE NULL END AS eq_cd_f
  FROM
    do_mstmeq_cd
    LEFT JOIN mst_equipment AS meq ON do_mstmeq_cd.meq_code = meq.equipment_cd
    LEFT JOIN do_mstmeq_class_cd ON do_mstmeq_class_cd.meq_class_code = meq.class_cd
  WHERE meq.in_hospital_cd_1 IS NOT NULL
  ORDER BY e01f asc) AS order_code_middle_F
)
, order_code_up_S AS (
SELECT DISTINCT ON (e01s)* FROM (
  SELECT 
    CASE WHEN (SELECT LEFT(in_hospital_cd_1, 8) FROM mst_equipment AS meq 
                 WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                   AND meq.in_hospital_cd_1 IS NOT NULL) IS NULL
         THEN (SELECT LEFT(in_hospital_cd_1, 8) FROM mst_dialyzer AS dia 
                 WHERE dia.dialyzer_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                   AND dia.in_hospital_cd_1 IS NOT NULL)
         ELSE (SELECT LEFT(in_hospital_cd_1, 8) FROM mst_equipment AS meq 
                 WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                   AND meq.in_hospital_cd_1 IS NOT NULL) END AS e01s,
    CASE WHEN 0 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(json_idx :: text, ''999999999999'') ELSE NULL END AS login_ord_s
  FROM
    ord_main_do AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info :: json) with ordinality as tmp(equip, json_idx)
  ORDER BY e01s, login_ord_s asc) AS order_code_middle_S
)
, dia_data_order AS (
SELECT DISTINCT item_cd, CASE type_name WHEN ''ダイアライザ'' THEN 
    (SELECT dialyzer_cd FROM mst_dialyzer WHERE item_cd = in_hospital_cd_1 AND mst_dialyzer.facility_cd = @facilityCd) ELSE 0 END AS dia_cd
FROM data_all
)
, do_data AS (
SELECT detail_id, item_cd, name, amounttest, syoumouhinOrder
    , (SELECT login_ord_s FROM order_code_up_S WHERE e01s = item_cd) AS login_ord
		, CASE WHEN (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = item_cd) IS NULL THEN 0 ELSE (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = item_cd) END AS cl_cd
    , (SELECT eq_cd_f FROM order_code_up_F WHERE e01f = item_cd) AS eq_cd
    , (SELECT dia_cd FROM dia_data_order WHERE dia_data_order.item_cd = do_data_group.item_cd) AS dia_cd
FROM  do_data_group
)
SELECT detail_id, item_cd, name, amounttest, syoumouhinOrder, login_ord, cl_cd, eq_cd, dia_cd
FROM do_data
ORDER BY syoumouhinOrder,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END, dia_cd, item_cd
limit (SELECT
    (case WHEN (COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''))=''0'' THEN 10 ELSE 108 END) AS staff_cd
     FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
     WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
				AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
        AND info ->> ''key1'' = ''DIALYSISSEND''
        AND info ->> ''key2'' = ''EQUIP_OUTPUT'')',2,'[{}]','1','{"applications": [4]}',NULL,'日機装)実績)中止時）医材繰り返し部','2022-07-27 01:34:23.636',CURRENT_TIMESTAMP,NULL);
