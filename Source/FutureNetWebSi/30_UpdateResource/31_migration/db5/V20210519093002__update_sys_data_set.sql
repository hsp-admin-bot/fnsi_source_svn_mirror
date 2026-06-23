UPDATE sys_data_set SET sql = 'with om as(
  select * from ord_main where is_del = ''0''
)
,dz as(
  select * from mst_dialyzer where is_del = ''0'' and is_disp = ''1''
)
, kr as(
  select * from mst_kur where is_del = ''0''
)
, bd as(
  select * from mst_bed where is_del = ''0'' and is_disp = ''1''
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

SELECT to_timestamp(treat_date,''YYYYMMDD'') as treat_date,kind,Name,kur_cd,kur_name,SUM(Amount) as amount,unit,bed_name,pat_id,in_hospital_cd_1,in_hospital_cd_2,in_hospital_cd_3,in_hospital_cd_4
FROM (
    SELECT 1 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,''ダイアライザ'' as kind,dz.model_number AS Name,1 AS Amount,COALESCE(om.ind_cond_info::json#>>''{5,unit}'','''') AS Unit,dz.in_hospital_cd_1,dz.in_hospital_cd_2,dz.in_hospital_cd_3,dz.in_hospital_cd_4 FROM om LEFT OUTER JOIN dz ON TO_NUMBER(om.ind_cond_info::json#>>''{5,value}'',''99999999'')=dz.dialyzer_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{5,value}'' IS NOT NULL
    UNION ALL
    --吸着カラム
    SELECT 2 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4 FROM om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{6,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{6,value}'' IS NOT NULL
    UNION ALL
    --1次膜
    SELECT 3 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4 FROM om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{7,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{7,value}'' IS NOT NULL
    UNION ALL
    --2次膜
    SELECT 4 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4 FROM om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{8,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{8,value}'' IS NOT NULL
    UNION ALL
    --穿刺針(A針)
    SELECT 5 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4 FROM om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{9,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{9,value}'' IS NOT NULL
    UNION ALL
    --穿刺針(V針)
    SELECT 5 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4 FROM om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{10,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{10,value}'' IS NOT NULL
    UNION ALL
    --穿刺針(SN)
    SELECT 6 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4 FROM om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{11,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>''{11,value}'' IS NOT NULL
    UNION ALL
    --血液回路
    SELECT 7 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4 FROM om LEFT OUTER JOIN eq ON TO_NUMBER(om.ind_cond_info::json#>>''{13,value}'',''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>''{13,value}'' IS NOT NULL
    UNION ALL
    --透析液
    SELECT 8 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(mdc.class_name,'''') as kind,md.medicine_name AS Name,TO_NUMBER(om.ind_cond_info::json#>>''{17,value}'',''99999999.99'') AS Amount,COALESCE(md.unit,'''') AS Unit,md.in_hospital_cd_1,md.in_hospital_cd_2,md.in_hospital_cd_3,md.in_hospital_cd_4 FROM om LEFT OUTER JOIN md ON TO_NUMBER(om.ind_cond_info::json#>>''{15,value}'',''99999999'')=md.medicine_cd LEFT OUTER JOIN mdc ON md.class_cd=mdc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>''{15,value}'' IS NOT NULL
    UNION ALL
    --補液
    SELECT 9 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(mdc.class_name,'''') as kind,md.medicine_name AS Name,TO_NUMBER(om.ind_cond_info::json#>>''{22,value}'',''99999999.99'') AS Amount,COALESCE(md.unit,'''') AS Unit,md.in_hospital_cd_1,md.in_hospital_cd_2,md.in_hospital_cd_3,md.in_hospital_cd_4 FROM om LEFT OUTER JOIN md ON TO_NUMBER(om.ind_cond_info::json#>>''{19,value}'',''99999999'')=md.medicine_cd LEFT OUTER JOIN mdc ON md.class_cd=mdc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>''{19,value}'' IS NOT NULL
    UNION ALL
    --抗凝固剤
    SELECT 10 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(mdc.class_name,'''') as kind,md.medicine_name AS Name,CEIL(((TO_NUMBER(om.ind_cond_info::json#>>''{26,value}'',''99999999.99'')+TO_NUMBER(om.ind_cond_info::json#>>''{28,value}'',''99999999.99''))/(case when md.unit_converted_amount is null or md.unit_converted_amount =0 then 1 else md.unit_converted_amount end ))*(case when md.unit_converted_amount_second is null or md.unit_converted_amount_second =0 then 1 else md.unit_converted_amount_second end ) ) AS Amount,COALESCE(md.unit,'''') AS Unit,md.in_hospital_cd_1,md.in_hospital_cd_2,md.in_hospital_cd_3,md.in_hospital_cd_4 FROM om LEFT OUTER JOIN md ON TO_NUMBER(om.ind_cond_info::json#>>''{25,value}'',''99999999'')=md.medicine_cd LEFT OUTER JOIN mdc ON md.class_cd=mdc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{25,value}'' IS NOT NULL
    UNION ALL 
    --投薬
    SELECT 11 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(mdc.class_name,'''') as kind,md.medicine_name as Name,CEIL(((TO_NUMBER(medi ->> ''amount'' ,''99999999.99''))/(case when md.unit_converted_amount is null or md.unit_converted_amount =0 then 1 else md.unit_converted_amount end ))*(case when md.unit_converted_amount_second is null or md.unit_converted_amount_second =0 then 1 else md.unit_converted_amount_second end ) ) as Amount,COALESCE(md.unit_second,COALESCE(md.unit,'''')) AS Unit,md.in_hospital_cd_1,md.in_hospital_cd_2,md.in_hospital_cd_3,md.in_hospital_cd_4 FROM om CROSS JOIN LATERAL json_array_elements (om.ind_medi_info :: json) medi LEFT OUTER JOIN md ON TO_NUMBER(medi ->> ''cd'' ,''99999999'')=md.medicine_cd LEFT OUTER JOIN mdc ON md.class_cd=mdc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos)
    UNION ALL 
    --医材
    SELECT 12 as disp_order,om.treat_date,kr.kur_cd,COALESCE(kr.kur_name,''未登録'') as kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name as Name,(TO_NUMBER(eqi ->> ''amount'' ,''99999999.99'')) as Amount,COALESCE(eq.unit,'''') AS Unit,eq.in_hospital_cd_1,eq.in_hospital_cd_2,eq.in_hospital_cd_3,eq.in_hospital_cd_4 FROM om CROSS JOIN LATERAL json_array_elements (om.ind_equip_info :: json) eqi LEFT OUTER JOIN eq ON TO_NUMBER(eqi ->> ''cd'' ,''99999999'')=eq.equipment_cd LEFT OUTER JOIN eqc ON eq.class_cd=eqc.class_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd LEFT OUTER JOIN bd ON om.ind_bed_cd=bd.bed_cd WHERE om.ord_no IN (@ordNos)  
) AS EquipmentList
GROUP BY treat_date,kind,Name,kur_cd,kur_name,Unit,bed_name,pat_id,disp_order,in_hospital_cd_1,in_hospital_cd_2,in_hospital_cd_3,in_hospital_cd_4
ORDER BY kind,name,kur_cd,kur_name,bed_name,pat_id,disp_order
;' WHERE sql_cd = 11;
