DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (9, 190);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9, 'with dz as(
select * from mst_dialyzer where is_del = ''0'' and is_disp = ''1''
)
, kr as(
select * from mst_kur where is_del = ''0''
)
, eq as(
select * from mst_equipment where is_del = ''0'' and is_disp = ''1''
)
, eqc as(
select * from mst_equipment_class where is_del = ''0'' and is_disp = ''1''
)
, md as(
select * from mst_medicine where is_del = ''0'' and is_disp = ''1''
)
, mdc as(
select * from mst_medicine_class where is_del = ''0'' and is_disp = ''1''
)

SELECT ord_no,disp_order,to_timestamp(treat_date,''YYYYMMDD'') as treat_date,kind,Name,SUM(Amount) as amount,unit,in_hospital_cd_1,in_hospital_cd_2,in_hospital_cd_3,in_hospital_cd_4, class_cd, cd, do_action
FROM (
SELECT om.ord_no as ord_no,1 as disp_order,om.treat_date,''ダイアライザ'' as kind,dz.model_number AS Name,1 AS Amount,COALESCE(om.ind_cond_info::json#>>''{5,unit}'','''') AS Unit,dz.in_hospital_cd_1,dz.in_hospital_cd_2,dz.in_hospital_cd_3,dz.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''ダイアライザ'' as do_action FROM ord_main om LEFT OUTER JOIN dz ON TO_NUMBER(om.ind_cond_info::json#>>''{5,value}'',''99999999'')=dz.dialyzer_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{5,value}'' IS NOT NULL
AND dz.dialyzer_cd IN (@diaIds) and om.is_del = ''0''
UNION ALL
--吸着カラム
SELECT om.ord_no as ord_no,2 as disp_order,om.treat_date,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''吸着カラム'' as do_action FROM ord_main om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{6,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{6,value}'' IS NOT NULL
AND eq.class_cd IN (@eqIds) and om.is_del = ''0''
UNION ALL
--1次膜
SELECT om.ord_no as ord_no,3 as disp_order,om.treat_date,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''1次膜'' as do_action FROM ord_main om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{7,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{7,value}'' IS NOT NULL
AND eq.class_cd IN (@eqIds) and om.is_del = ''0''
UNION ALL
--2次膜
SELECT om.ord_no as ord_no,4 as disp_order,om.treat_date,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''2次膜'' as do_action FROM ord_main om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{8,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{8,value}'' IS NOT NULL
AND eq.class_cd IN (@eqIds) and om.is_del = ''0''
UNION ALL
--穿刺針(A針)
SELECT om.ord_no as ord_no,5 as disp_order,om.treat_date,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''穿刺針(A針)'' as do_action FROM ord_main om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{9,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{9,value}'' IS NOT NULL
AND eq.class_cd IN (@eqIds) and om.is_del = ''0''
UNION ALL
--穿刺針(V針)
SELECT om.ord_no as ord_no,5 as disp_order,om.treat_date,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''穿刺針(V針)'' as do_action FROM ord_main om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{10,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{10,value}'' IS NOT NULL
AND eq.class_cd IN (@eqIds) and om.is_del = ''0''
UNION ALL
--穿刺針(SN)
SELECT om.ord_no as ord_no,6 as disp_order,om.treat_date,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''穿刺針(SN針)'' as do_action FROM ord_main om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{11,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>''{11,value}'' IS NOT NULL
AND eq.class_cd IN (@eqIds) and om.is_del = ''0''
UNION ALL
--血液回路
SELECT om.ord_no as ord_no,7 as disp_order,om.treat_date,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''血液回路'' as do_action FROM ord_main om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{13,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>''{13,value}'' IS NOT NULL
AND eq.class_cd IN (@eqIds) and om.is_del = ''0''
UNION ALL
--透析液
SELECT om.ord_no as ord_no,8 as disp_order,om.treat_date,COALESCE(mdc.class_name,'''') as kind,md.medicine_name AS Name,TO_NUMBER(om.ind_cond_info::json#>>''{17,value}'',''99999999.99'') AS Amount,COALESCE(md.unit,'''') AS Unit,md.in_hospital_cd_1,md.in_hospital_cd_2,md.in_hospital_cd_3,md.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''透析液'' as do_action FROM ord_main om LEFT OUTER JOIN md ON TO_NUMBER(om.ind_cond_info::json#>>''{15,value}'',''99999999'')=md.medicine_cd LEFT OUTER JOIN mdc ON md.class_cd=mdc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>''{15,value}'' IS NOT NULL
AND md.class_cd IN (@medIds) and om.is_del = ''0''
UNION ALL
--補液
SELECT om.ord_no as ord_no,8 as disp_order,om.treat_date,COALESCE(mdc.class_name,'''') as kind,md.medicine_name AS Name,TO_NUMBER(om.ind_cond_info::json#>>''{22,value}'',''99999999.99'') AS Amount,COALESCE(md.unit,'''') AS Unit,md.in_hospital_cd_1,md.in_hospital_cd_2,md.in_hospital_cd_3,md.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''補液'' as do_action FROM ord_main om LEFT OUTER JOIN md ON TO_NUMBER(om.ind_cond_info::json#>>''{19,value}'',''99999999'')=md.medicine_cd LEFT OUTER JOIN mdc ON md.class_cd=mdc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>''{19,value}'' IS NOT NULL
AND md.class_cd IN (@medIds) and om.is_del = ''0''
UNION ALL
--抗凝固剤
SELECT om.ord_no as ord_no,9 as disp_order,om.treat_date,COALESCE(mdc.class_name,'''') as kind,md.medicine_name AS Name,COALESCE(CEIL(((TO_NUMBER(om.ind_cond_info::json#>>''{26,value}'',''99999999.99'')+TO_NUMBER(om.ind_cond_info::json#>>''{28,value}'',''99999999.99''))/case when md.unit_converted_amount is null or md.unit_converted_amount= 0 then 1 else md.unit_converted_amount end)*(case when md.unit_converted_amount_second is null or md.unit_converted_amount_second =0 then 1 else md.unit_converted_amount_second end ) ),(TO_NUMBER(om.ind_cond_info::json#>>''{26,value}'',''99999999.99'')+TO_NUMBER(om.ind_cond_info::json#>>''{28,value}'',''99999999.99''))) AS Amount,COALESCE(md.unit_second,COALESCE(md.unit,'''')) AS Unit,md.in_hospital_cd_1,md.in_hospital_cd_2,md.in_hospital_cd_3,md.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''抗凝固剤'' as do_action FROM ord_main om LEFT OUTER JOIN md ON TO_NUMBER(om.ind_cond_info::json#>>''{25,value}'',''99999999'')=md.medicine_cd LEFT OUTER JOIN mdc ON md.class_cd=mdc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>''{25,value}'' IS NOT NULL
AND md.class_cd IN (@medIds) and om.is_del = ''0''
UNION ALL 
--投薬
SELECT om.ord_no as ord_no,10 as disp_order,om.treat_date,COALESCE(mdc.class_name,'''') as kind,md.medicine_name as Name,COALESCE(CEIL(((TO_NUMBER(medi ->> ''amount'' ,''99999999.99''))/case when md.unit_converted_amount is null or md.unit_converted_amount= 0 then 1 else md.unit_converted_amount end)*(case when md.unit_converted_amount_second is null or md.unit_converted_amount_second =0 then 1 else md.unit_converted_amount_second end ) ),TO_NUMBER(medi ->> ''amount'' ,''99999999.99'')) as Amount,COALESCE(md.unit_second,COALESCE(md.unit,'''')) AS Unit,md.in_hospital_cd_1,md.in_hospital_cd_2,md.in_hospital_cd_3,md.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''投薬'' as do_action FROM ord_main as om CROSS JOIN LATERAL json_array_elements (om.ind_medi_info :: json) medi LEFT OUTER JOIN md ON TO_NUMBER(medi ->> ''cd'' ,''99999999'')=md.medicine_cd LEFT OUTER JOIN mdc ON md.class_cd=mdc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos)  
AND md.class_cd IN (@medIds) and om.is_del = ''0''
UNION ALL 
--医材
SELECT om.ord_no as ord_no,11 as disp_order,om.treat_date,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name as Name,(TO_NUMBER(eqi ->> ''amount'' ,''99999999.99'')) as Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4, eq.class_cd :: INTEGER as class_cd, eq.equipment_cd :: TEXT as cd, ''医材'' as do_action FROM ord_main as om CROSS JOIN LATERAL json_array_elements (om.ind_equip_info :: json) eqi LEFT OUTER JOIN eq ON TO_NUMBER(eqi ->> ''cd'' ,''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos)  
AND eq.class_cd IN (@eqIds) and om.is_del = ''0''
) AS EquipmentList
GROUP BY ord_no,disp_order,treat_date,kind,Name,Unit,in_hospital_cd_1,in_hospital_cd_2,in_hospital_cd_3,in_hospital_cd_4,class_cd,cd,do_action
ORDER BY disp_order,kind
;', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (190, 'with  ord_tbl AS (
    SELECT
        ord_no
      , facility_cd
      , json_idx
      , to_date(treat_date, ''yyyymmdd'') as treat_date
      , treat_week
      , info
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
    WHERE
        is_del = ''0''
    AND ord_no =  @ordNo
),
medicine_order AS (

  select
    one_json ->> ''code'' as medicine_cd
    , json_idx as medicine_cd_order 
from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd = (select facility_cd from ord_tbl limit 1)
    and master_physical_name = ''mst_medicine''

),
medicine_tbl as (
  select
    *
  from
    mst_medicine
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicine.is_disp = ''1''
  and
    mst_medicine.is_del = ''0''
), medicine_mix_tbl as (
select
     mix.*
    , medimix ->> ''cd'' as medi_cd
    , medimix ->> ''amount'' as amount 
from
    mst_medicine_mix mix 
    CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx) 
  where
    mix.facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mix.is_disp = ''1''
  and
    mix.is_del = ''0''
), medicine_class_tbl as (
  select
    *
  from
    mst_medicine_class
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicine_class.is_disp = ''1''
  and
    mst_medicine_class.is_del = ''0''
), timing_tbl as (
  select
    *
  from
    mst_medicate_timing
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_medicate_timing.is_disp = ''1''
  and
    mst_medicate_timing.is_del = ''0''
), procedure_tbl as (
  select
    *
  from
    mst_procedure
  where
    facility_cd  = (select facility_cd from ord_tbl limit 1)
  and
    mst_procedure.is_disp = ''1''
  and
    mst_procedure.is_del = ''0''
)
select A.*,save.receipt_value from (
select
   json_idx
   ,ord_no
   ,ord.facility_cd
   , info ->> ''cd'' as cd
   , med.medicine_name
   , med.unit as medicine_unit
   , info ->> ''medicine_type'' as medicine_type
   , cast(info ->> ''amount'' AS NUMERIC) as amount
   , med.class_cd as class_cd
   , med_cls.class_name as class_name
   , med_cls.class_type as class_type
   , tim.medicate_timing_name
   , pro.pricedure_name
   , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
   , info ->> ''date_interval'' as date_interval
   , info ->> ''comment'' as comment
   , info ->> ''ind_user_id'' as ind_user_id
   , info ->> ''upd_user_id'' as upd_user_id
   , med.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
   , med.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
   , med.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
    ,med.unit_second as   unit_second    
from
  ord_tbl as ord
  left join medicine_tbl as med on info ->> ''cd'' = med.medicine_cd::text
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join timing_tbl as tim on ord.info ->> ''timing_cd'' = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on info ->> ''procedure_cd'' = pro.procedure_cd::text
where
ord.info ->> ''medicine_type'' = ''1''

union 
 
select
     json_idx
   ,ord_no
   ,ord.facility_cd
   , mixtemp.medi_cd  :: text  as cd
   , med.medicine_name
   , med.unit as medicine_unit
   , info ->> ''medicine_type'' as medicine_type
   , (info ->> ''amount'') :: NUMERIC * mixtemp.amount :: NUMERIC  as amount
   , med.class_cd as class_cd
   , med_cls.class_name as class_name
   , med_cls.class_type as class_type
   , tim.medicate_timing_name
   , pro.pricedure_name
   , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
   , info ->> ''date_interval'' as date_interval
   , info ->> ''comment'' as comment
   , info ->> ''ind_user_id'' as ind_user_id
   , info ->> ''upd_user_id'' as upd_user_id
   , med.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
   , med.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
   , med.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
   , case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
       then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
   ,med.unit_second as   unit_second  
from
  ord_tbl as ord
  inner join  medicine_mix_tbl  mixtemp on (mixtemp.medicine_mix_cd :: text= info ->> ''cd'')
  left join medicine_tbl as med on  med.medicine_cd::text = mixtemp.medi_cd 
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join timing_tbl as tim on ord.info ->> ''timing_cd'' = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on info ->> ''procedure_cd'' = pro.procedure_cd::text
where
ord.info ->> ''medicine_type'' = ''2''
) A  
left join medicine_order O on (A.cd = O.medicine_cd)
left join ord_material_save as save on (save.supplies_base_no = A.ord_no and A.facility_cd = save.facility_cd and A.cd  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'')
  order by json_idx asc ,medicine_cd_order asc
  ', 2, '[{"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_type", "data_name": "分類区分", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "dial_treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "dial_init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬（分解）", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dial_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "dial_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dial_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量（レセ）", "data_type": "decimal", "conv_table": [], "data_class": "投薬（分解）", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位（レセ）", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dial_pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dial_medicate_timing_name", "data_name": "投与時間帯", "data_type": "strnig", "conv_table": [], "data_class": "投薬（分解）", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dial_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "dial_ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "dial_upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬（分解）", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "dial_date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/3月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬（分解）", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬（分解） @ordNo 使用', '2021-10-08 09:47:36', CURRENT_TIMESTAMP, NULL);
