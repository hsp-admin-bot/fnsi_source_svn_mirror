DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-19);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-19, 'select 
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
limit 10', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示）指示医材コード', '2020-04-10 16:42:55.734', CURRENT_TIMESTAMP, NULL);
