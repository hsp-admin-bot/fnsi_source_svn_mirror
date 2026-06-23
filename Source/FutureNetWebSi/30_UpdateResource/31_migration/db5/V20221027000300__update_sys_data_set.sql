delete from ntss.sys_data_set where sql_cd in (9);
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

SELECT disp_order,to_timestamp(treat_date,''YYYYMMDD'') as treat_date,kind,Name,SUM(Amount) as amount,unit,in_hospital_cd_1,in_hospital_cd_2,in_hospital_cd_3,in_hospital_cd_4, class_cd, cd, do_action 
FROM (
SELECT om.ord_no as ord_no,1 as disp_order,om.treat_date,''ダイアライザ'' as kind,dz.model_number AS Name,1 AS Amount,COALESCE(om.ind_cond_info::json#>>''{5,unit}'','''') AS Unit,dz.in_hospital_cd_1,dz.in_hospital_cd_2,dz.in_hospital_cd_3,dz.in_hospital_cd_4, 0 as class_cd, ''0'' as cd, ''ダイアライザ'' as do_action FROM ord_main om LEFT OUTER JOIN dz ON TO_NUMBER(om.ind_cond_info::json#>>''{5,value}'',''99999999'')=dz.dialyzer_cd LEFT OUTER JOIN kr ON om.ind_kur_cd=kr.kur_cd WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{5,value}'' IS NOT NULL and om.is_del = ''0''
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
GROUP BY disp_order,treat_date,kind,Name,Unit,in_hospital_cd_1,in_hospital_cd_2,in_hospital_cd_3,in_hospital_cd_4,class_cd,cd,do_action
HAVING SUM(Amount) > 0 
ORDER BY disp_order,kind
;', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
