DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (-191);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-191, 'WITH do_order_data_from AS (
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
	5 as syoumouhinOrder
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
	6 as syoumouhinOrder
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
	7 as syoumouhinOrder
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
	 8 as syoumouhinOrder
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
	5 as syoumouhinOrder
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
	6 as syoumouhinOrder
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
	7 as syoumouhinOrder
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
	 8 as syoumouhinOrder
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
		and ''0'' =(
		select count(*) from ord_main where ord_no =@ordNo)
) all_equip
where
 all_equip.cd1 is not null)
 )
, do_data_group AS (
SELECT 
    (detail_id:: text) as detail_id, cd1, name, sum(amount) as amount
        , CASE WHEN SUM(syoumouhinOrder) > 8 THEN SUM(syoumouhinOrder) - 8 ELSE SUM(syoumouhinOrder) END AS syoumouhinOrder
FROM  
    data_middle_all
GROUP BY cd1, detail_id :: text, name
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
)
, do_data AS (
SELECT detail_id, cd1, cd2, cd3, cd4, name, amount, unit, syoumouhinOrder
    , (SELECT login_ord_s FROM order_code_up_S WHERE e01s = cd1) AS login_ord
    , (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) AS cl_cd
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
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END
limit 12', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示)中止時）指示医材1コード', '2022-06-18 05:06:30.633', CURRENT_TIMESTAMP, NULL);
