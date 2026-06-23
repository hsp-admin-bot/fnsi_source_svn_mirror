DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (-18,-19,-494,-497);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-19, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1 
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, order_code AS (
SELECT  
    meq.in_hospital_cd_1 AS e01,
      CASE WHEN 0 in (SELECT a1 FROM do_order_data_from) THEN json_idx ELSE NULL END AS login_ord,
      CASE WHEN 1 in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( equip ->> ''class_cd'', ''999999999999'' ) ELSE NULL END AS cl_cd,
      CASE WHEN 2 in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( equip ->> ''cd'', ''999999999999'' ) ELSE NULL END AS eq_cd
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(equip, json_idx)
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
    WHERE
    meq.in_hospital_cd_1 IS NOT NULL
    AND ord.ord_no = @ordNo
)
, data_all AS (
select 
 ''指示医材'' as detail_id,
 row_number() over() as equip_no,
 all_equip.equip_class_type as class,
 all_equip.cd1 as cd1,
 all_equip.cd2 as cd2,
 all_equip.cd3 as cd3,
 all_equip.cd4 as cd4,
 all_equip.equip_name as name,
 all_equip.amount as amount,
 all_equip.unit as unit
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
  meqad.unit
from
  ord_main as ord
left outer join
  mst_equipment as meqad
 on
  meqad.equipment_cd = TO_NUMBER (ord.ind_cond_info->''6''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo

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
  meqpr.unit
 from
  ord_main as ord
  left outer join
  mst_equipment as meqpr
 on
  meqpr.equipment_cd = TO_NUMBER (ord.ind_cond_info->''7''->>''value'',''999999999999'')
  where
  ord.ord_no = @ordNo

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
  meqse.unit
  from
  ord_main as ord
  left outer join
  mst_equipment as meqse
 on
  meqse.equipment_cd = TO_NUMBER (ord.ind_cond_info->''8''->>''value'',''999999999999'')
  where
  ord.ord_no = @ordNo

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
  meqa.unit
 from
  ord_main ord
   left outer join
   mst_equipment as meqa
  on
   meqa.equipment_cd = TO_NUMBER (ord.ind_cond_info->''9''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

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
  meqv.unit
  from
  ord_main ord
   left outer join
   mst_equipment as meqv
  on
   meqv.equipment_cd = TO_NUMBER (ord.ind_cond_info->''10''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

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
  meqsn.unit
   from
  ord_main ord
  left outer join
   mst_equipment as meqsn
  on
   meqsn.equipment_cd = TO_NUMBER (ord.ind_cond_info->''11''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo

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
  meqbc.unit
from
  ord_main as ord
 left outer join
  mst_equipment as meqbc
 on
  meqbc.equipment_cd = TO_NUMBER (ord.ind_cond_info->''13''->>''value'',''999999999999'')
where
 ord.ord_no = @ordNo

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
   meq.unit as equip_unit
    from
      mst_equipment_class as meqc,
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_equip_info :: json) equip
 left outer join
   mst_equipment as meq
 on
   meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
    where
      meq.class_cd = meqc.class_cd and
      ord.ord_no = @ordNo
) all_equip
where
 all_equip.cd1 is not null
)
SELECT 
    detail_id, equip_no, class, cd1, cd2, cd3, cd4, name, amount, unit, login_ord, cl_cd, eq_cd
FROM        
    data_all
        LEFT JOIN order_code ON order_code.e01 = data_all.cd1
ORDER BY
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = 0 THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = 1 THEN cl_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = 2 THEN eq_cd END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = 0 THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = 1 THEN cl_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = 2 THEN eq_cd END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = 0 THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = 1 THEN cl_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END
limit 108', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示）指示医材コード', '2020-04-10 16:42:55.734', CURRENT_TIMESTAMP, NULL);
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
        ,COUNT(medi_cd1) as medi_back
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
limit 135', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示）投与薬剤コード', '2020-04-10 15:28:38.712', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-494, 'SELECT
  ''医材'' AS detail_id,
  TRIM (all_cost.e01) AS item_cd,
  all_cost.e02 AS name,
  all_cost.e03 AS type_name,
  all_cost.e04 AS class_name,
  COALESCE(all_cost.e05, ''0'') AS amount,
  ((COALESCE(all_cost.e05, ''0'')::FLOAT)*100)::INTEGER AS amounttest,
  COALESCE(all_cost.e06, '''') AS unit 
FROM
  (
    SELECT--血液回路情報
    ''血液回路'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''血液回路'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION
    SELECT--A針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''A針'' AS e03,
    ''1'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION
    SELECT--V針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''V針'' AS e03,
    ''2'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION
    SELECT--SN針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''SN針'' AS e03,
    ''3'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION
    SELECT--医材内穿刺針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''穿刺針'' AS e03,
    ''0'' AS e04,
    equip ->> ''amount'' AS e05,
    equip ->> ''unit'' AS e06 
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' ) 
  WHERE
    equip ->> ''class_type'' IN ( ''2'', ''3'' ) 
    AND ord.ord_no = @ordNo 
  UNION
    SELECT--医材情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''医材'' AS e03,
    ''0'' AS e04,
    equip ->> ''amount'' AS e05,
    equip ->> ''unit'' AS e6 
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' ) 
  WHERE
    equip ->> ''equip_type'' = ''0'' 
    AND (equip ->> ''class_type'' NOT IN ( ''2'', ''3'' ) or equip ->>''class_type'' is null)
    AND ord.ord_no = @ordNo 
  UNION
    SELECT--1次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo
      and ''0''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
    SELECT--2次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
        and ''0''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
   facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
    SELECT--吸着カラム情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo
      and ''0''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd =@facilityCd
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')  
  ) all_cost 
WHERE
  all_cost.e01 IS NOT NULL 
ORDER BY
  all_cost.e01
    limit (SELECT
        (case WHEN (COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''))=''0'' THEN 10 ELSE 108 END) AS staff_cd 
        FROM
            mst_coop_ini AS ini 
            CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
        WHERE
            facility_cd = @facilityCd 
            AND is_del = ''0'' 
            AND info ->> ''key1'' = ''CONSUMABLE_ITEAMS_NUMBER'' 
            AND info ->> ''key2'' = ''OUT_PUT_NUMBER'')', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）医材繰り返し部', '2020-05-22 11:43:49.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-497, 'SELECT
  ''薬剤'' AS detail_id,
  all_cost.e01 AS item_cd,
  (sum(all_cost.e04::float)*100)::INTEGER AS amount,
  COALESCE(all_cost.e05, '''') AS unit,
    (select count(all_cost1.e01) from (SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07 
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' ) 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO'' 
    AND ord.ord_no =@ordNo  
  UNION
    SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
       meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
      and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
    SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
         meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
        and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
    SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
     meq.unit AS e05,
    ''1'' AS e06,
    ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
      and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
     SELECT--投与薬剤情報(調製)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    COALESCE (
      (
      CASE
          mmxd ->> ''solvent'' 
          WHEN ''1'' THEN
            to_char( to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
          ELSE 
        CASE WHEN mmx.amount_unit IS NULL OR  mmxd ->> ''amount'' IS NULL OR (mmx.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' )) = 0 
            THEN ''0.00'' 
            ELSE to_char( to_number( medi ->> ''amount'', ''99999.99'' ) / mmx.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
            END 
        END 
        ),
        ''0.00'' 
      ) AS e04,
      COALESCE ( mmd.unit_second, mmd.unit ) AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
      AND ord.ord_no = @ordNo 
  UNION
      SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    WHERE
      ord.ord_no = @ordNo ) as all_cost1 where all_cost1.e01 = all_cost.e01) count
FROM
  (
    SELECT--1次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''1'' AS e04,
       meq.unit AS e05,
    ''1'' AS e06,
      ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
      and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
    SELECT--2次膜情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''1'' AS e04,
       meq.unit AS e05,
    ''1'' AS e06,
      ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo  
        and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
  UNION
    SELECT--吸着カラム情報
    ''投与薬剤'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''1'' AS e04,
       meq.unit AS e05,
    ''1'' AS e06,
      ''NULL'' AS e07 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
      and ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONSUMABLES_CODE'' 
    AND info ->> ''key2'' = ''POTION_STATUS'')
    UNION
    SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07 
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' ) 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND COALESCE ( mmd.in_hospital_cd_1, ''ZERO'' ) <> ''ZERO'' 
    AND ord.ord_no =@ordNo 
  UNION
     SELECT--投与薬剤情報(調製)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    COALESCE (
      (
      CASE
          mmxd ->> ''solvent''
          WHEN ''1'' THEN
            to_char( to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
          ELSE 
        CASE WHEN mmx.amount_unit IS NULL OR  mmxd ->> ''amount'' IS NULL OR (mmx.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' )) = 0 
            THEN ''0.00'' 
            ELSE to_char( to_number( medi ->> ''amount'', ''99999.99'' ) / mmx.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
            END 
        END 
        ),
        ''0.00'' 
      ) AS e04,
      COALESCE ( mmd.unit_second, mmd.unit ) AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
      AND ord.ord_no = @ordNo 
  UNION
      SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    WHERE
      ord.ord_no = @ordNo 
    ) all_cost 
WHERE
  all_cost.e01 IS NOT NULL
    group by all_cost.e01,all_cost.e05
    ORDER BY all_cost.e01
    limit 135
', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）薬剤の投薬回数のSQL)', '2022-05-09 05:52:21.853', CURRENT_TIMESTAMP, NULL);
