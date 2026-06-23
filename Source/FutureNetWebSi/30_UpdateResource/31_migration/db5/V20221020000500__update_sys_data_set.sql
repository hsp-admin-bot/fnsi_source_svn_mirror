delete from ntss.sys_data_set where sql_cd = '16';
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (16, 'WITH plan_time AS (
	SELECT om.ord_no, om.ind_cond_info::json#>>''{1, value}'' AS plan_time, (pat_unique.physical_info::json->>0)::json->>''dw'' || '' Kg'' AS cond_dw, om.ind_cond_info::json#>>''{3, value}'' || '' Kg'' AS cond_tg_wei, om.ind_treatment_name AS cond_tre_nm, om.ind_cond_info::json#>>''{14, value}'' || '' mL/min'' AS cond_bld_fl
	FROM ord_main om
	INNER JOIN pat_unique ON om.pat_id = pat_unique.pat_id and pat_unique.is_del = ''0''
    WHERE om.ord_no IN (@ordNos) and om.is_del = ''0''
), mst_room_bed_group_1 AS (
	select * from mst_room_bed_group where is_del = ''0'' and is_disp = ''1'' and group_class = 1
), mst_room_bed_group_2 AS (
	select * from mst_room_bed_group where is_del = ''0'' and is_disp = ''1'' and group_class = 2
), EquipmentList_Tmp AS (
SELECT 
to_timestamp(treat_date,''YYYYMMDD'') as treat_date,kur_cd,kur_name,bed_name,bed_cd,pat_id,kind,Name
, amount
, unit
, function_class, area, ufr, koa, material, wetdry, disp_order, class_name, anticoagulant_name
, plan_time.plan_time, plan_time.cond_dw, plan_time.cond_tg_wei, plan_time.cond_tre_nm, plan_time.cond_bld_fl
, in_hospital_cd_1, in_hospital_cd_2
, equip_circuit
, cond_ac_shot
, cond_ac_spd
, cond_ac_dur_total
, cond_ip_use
, cond_ip_start
, cond_ip_spd
, cond_ip_shot_st
, cond_ip_shot
, cond_ip_off
, cond_ip_off_tm
, cond_ip_ok
, cond_ip_ok_tm
, cond_dl_fl
, cond_dl_am
, cond_dl_temp
, cond_rl_am
, cond_rl_sel
, cond_rl_use
, cond_rl_temp
, cond_rl_spd
, medi_timing
, medi_proc
, num_unit
, cond_va_dir
, cond_va
, equip_pnc_cls
FROM (
    WITH Anticoagulant AS (
	    SELECT om.ord_no, pat_id, treat_date, ind_kur_cd, ind_bed_cd, ind_cond_info
		, CASE WHEN om.ind_cond_info::json#>>''{25, medicine_type}'' = ''1'' THEN md.medicine_name ELSE mdx.medicine_mix_name END AS medicine_name
 		, CASE WHEN om.ind_cond_info::json#>>''{25, medicine_type}'' = ''1'' THEN md.unit ELSE mdx.unit END AS unit
		, om.ind_cond_info::json#>>''{25, medicine_type}'' as medicine_type
        , to_number(om.ind_cond_info::json#>>''{25,value}'',''9999999999'') as medicine_cd
    	FROM ord_main om
    	LEFT OUTER JOIN mst_medicine md ON (om.ind_cond_info::json#>>''{25, medicine_type}'' = ''1'' AND TO_NUMBER(om.ind_cond_info::json#>>''{25,value}'',''99999999'') = md.medicine_cd and md.is_del = ''0'' and md.is_disp = ''1'')
    	LEFT OUTER JOIN mst_medicine_mix mdx ON (om.ind_cond_info::json#>>''{25, medicine_type}'' = ''2'' AND TO_NUMBER(om.ind_cond_info::json#>>''{25,value}'',''99999999'') = mdx.medicine_mix_cd and mdx.is_del = ''0'' and mdx.is_disp = ''1'')
    	WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{25,value}'' IS NOT NULL and om.is_del = ''0''
    ), ord_dialysisLiquid AS (
	    SELECT om.ord_no, pat_id, treat_date, ind_kur_cd, ind_bed_cd, ind_cond_info
		, to_number(om.ind_cond_info::json#>>''{15,value}'', ''9999999999'') as medicine_cd
		, om.ind_cond_info::json#>>''{15, medicine_type}'' as medicine_type
		, om.ind_cond_info::json#>>''{16, value}'' as cond_dl_fl
		, om.ind_cond_info::json#>>''{17, value}'' as cond_dl_am
		, om.ind_cond_info::json#>>''{18, value}'' as cond_dl_temp
    	FROM ord_main om
	    WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{15,value}'' IS NOT NULL and om.is_del = ''0''
    ), ord_replenishLiquid AS (
	    SELECT om.ord_no, pat_id, treat_date, ind_kur_cd, ind_bed_cd, ind_cond_info
		, to_number(om.ind_cond_info::json#>>''{19,value}'', ''9999999999'') as medicine_cd
		, om.ind_cond_info::json#>>''{19, medicine_type}'' as medicine_type
    	FROM ord_main om
	    WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{19,value}'' IS NOT NULL and om.is_del = ''0''
    ), 	ord_medi AS (
	    SELECT om.ord_no, pat_id, treat_date, ind_kur_cd, ind_bed_cd
		, medi
		, to_number(medi->>''cd'', ''9999999999'') as cd
		, medi->>''medicine_type'' as medicine_type
		, medi->>''amount'' as amount
	    FROM ord_main as om CROSS JOIN LATERAL json_array_elements (om.ind_medi_info :: json) medi
	    WHERE om.ord_no IN (@ordNos) and om.is_del = ''0''
    )
	SELECT 1 as disp_order,om.treat_date,kr.kur_cd,kr.kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id,
    ''ダイアライザ'' as kind, dz.model_number AS Name, 1 AS Amount,COALESCE(om.ind_cond_info::json#>>''{5,unit}'','''') AS Unit
    , function_class, area || ''㎡'' as area, ufr, koa, material, wetdry, ''ダイアライザ'' as class_name, Anticoagulant.medicine_name as Anticoagulant_name, om.ord_no, dz.in_hospital_cd_1, dz.in_hospital_cd_2
	, eq.equipment_name AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, ''1本'' as num_unit
	, null as cond_va_dir
	, null as cond_va
	, null as equip_pnc_cls
    FROM ord_main om
    LEFT OUTER JOIN mst_dialyzer dz ON TO_NUMBER(om.ind_cond_info::json#>>''{5,value}'', ''9999999999'') = dz.dialyzer_cd and dz.is_del = ''0'' and dz.is_disp = ''1''
    LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd and kr.is_del = ''0''
	LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
	LEFT OUTER JOIN Anticoagulant ON om.ord_no=Anticoagulant.ord_no
	LEFT OUTER JOIN mst_equipment eq ON to_number(om.ind_cond_info::json#>>''{13,value}'', ''9999999999'') = eq.equipment_cd and eq.is_del = ''0'' and eq.is_disp = ''1''
	WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{5,value}'' IS NOT NULL and om.is_del = ''0''
    AND 0 NOT IN (@diaIds)
	UNION ALL
	--吸着カラム
	SELECT 2 as disp_order,om.treat_date,kr.kur_cd,kr.kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry, ''吸着カラム'' as class_name, null as Anticoagulant_name, om.ord_no, eq.in_hospital_cd_1, eq.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, concat(''1'', eq.unit) as num_unit
	, null as cond_va_dir
	, null as cond_va
	, null as equip_pnc_cls
    FROM ord_main om
	LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>''{6,value}'',''9999999999'')=eq.equipment_cd and eq.is_del = ''0'' and eq.is_disp = ''1''
	LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd and eqc.is_del = ''0'' and eqc.is_disp = ''1''
	LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
	LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
	WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{6,value}'' IS NOT NULL and om.is_del = ''0''
    AND eq.class_cd IN (@eqIds)
	UNION ALL
	--1次膜
	SELECT 3 as disp_order,om.treat_date,kr.kur_cd,kr.kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry, ''1次膜'' as class_name, null as Anticoagulant_name, om.ord_no, eq.in_hospital_cd_1, eq.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, concat(''1'', eq.unit) as num_unit
	, null as cond_va_dir
	, null as cond_va
	, null as equip_pnc_cls
    FROM ord_main om
 	LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>''{7,value}'',''9999999999'')=eq.equipment_cd and eq.is_del = ''0'' and eq.is_disp = ''1''
	LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd and eqc.is_del = ''0'' and eqc.is_disp = ''1''
	LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
	LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
	WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{7,value}'' IS NOT NULL and om.is_del = ''0''
    AND eq.class_cd IN (@eqIds)
	UNION ALL
	--2次膜
	SELECT 4 as disp_order,om.treat_date,kr.kur_cd,kr.kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry, ''2次膜'' as class_name, null as Anticoagulant_name, om.ord_no, eq.in_hospital_cd_1, eq.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, concat(''1'', eq.unit) as num_unit
	, null as cond_va_dir
	, null as cond_va
	, null as equip_pnc_cls
    FROM ord_main om 
    LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>''{8,value}'',''99999999'')=eq.equipment_cd and eq.is_del = ''0'' and eq.is_disp = ''1''
    LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd and eqc.is_del = ''0'' and eqc.is_disp = ''1''
    LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
    LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
	WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{8,value}'' IS NOT NULL and om.is_del = ''0''
    AND eq.class_cd IN (@eqIds)
	UNION ALL
	--穿刺針(A針)
	SELECT 5 as disp_order,om.treat_date,kr.kur_cd,kr.kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name
	, 1 AS Amount,COALESCE(eq.unit,'''') AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry, ''穿刺針(A針)'' as class_name, null as Anticoagulant_name, om.ord_no, eq.in_hospital_cd_1, eq.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, concat(''1'', eq.unit) as num_unit
	, va.va_direct as cond_va_dir
	, va.va_name as cond_va
	, ''A針'' as equip_pnc_cls
    FROM ord_main om
	LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>''{9,value}'',''9999999999'') = eq.equipment_cd and eq.is_del = ''0'' and eq.is_disp = ''1''
	LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd and eqc.is_del = ''0'' and eqc.is_disp = ''1''
	LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
	LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
	LEFT OUTER JOIN mst_va va ON to_number(om.ind_cond_info::json#>>''{2, value}'', ''9999999999'') = va.va_cd and va.is_del = ''0'' and va.is_disp = ''1''
	WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{9,value}'' IS NOT NULL and om.is_del = ''0''
    AND eq.class_cd IN (@eqIds)
	UNION ALL
	--穿刺針(V針)
	SELECT 5 as disp_order,om.treat_date,kr.kur_cd,kr.kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry, ''穿刺針(V針)'' as class_name, null as Anticoagulant_name, om.ord_no, eq.in_hospital_cd_1, eq.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, concat(''1'', eq.unit) as num_unit
	, null as cond_va_dir
	, null as cond_va
	, ''V針'' as equip_pnc_cls
    FROM ord_main om 
    LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>''{10,value}'',''99999999'')=eq.equipment_cd and eq.is_del = ''0'' and eq.is_disp = ''1''
    LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd and eqc.is_del = ''0'' and eqc.is_disp = ''1''
    LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
    LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
	WHERE om.ord_no IN (@ordNos) AND om.ind_cond_info::json#>>''{10,value}'' IS NOT NULL and om.is_del = ''0''
    AND eq.class_cd IN (@eqIds)
	UNION ALL
	--穿刺針(SN)
	SELECT 6 as disp_order,om.treat_date,kr.kur_cd,kr.kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name AS Name,1 AS Amount,COALESCE(eq.unit,'''') AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry, ''穿刺針(SN)'' as class_name, null as Anticoagulant_name, om.ord_no, eq.in_hospital_cd_1, eq.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, concat(''1'', eq.unit) as num_unit
	, null as cond_va_dir
	, null as cond_va
	, ''SN'' as equip_pnc_cls
    FROM ord_main om 
    LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>''{11,value}'',''99999999'')=eq.equipment_cd and eq.is_del = ''0'' and eq.is_disp = ''1''
    LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd and eqc.is_del = ''0'' and eqc.is_disp = ''1''
    LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
    LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
	WHERE om.ord_no IN (@ordNos)  AND om.ind_cond_info::json#>>''{11,value}'' IS NOT NULL and om.is_del = ''0''
    AND eq.class_cd IN (@eqIds)
	UNION ALL
	--透析液
	SELECT 8 as disp_order,om.treat_date,kr.kur_cd,kr.kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id
	, COALESCE(mdc.class_name,'''') as kind,md.medicine_name AS Name
	, TO_NUMBER(cond_dl_am, ''99999999.99'') AS Amount, COALESCE(md.unit,'''') AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry
	, ''透析液'' as class_name, null as Anticoagulant_name, om.ord_no, md.in_hospital_cd_1, md.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, om.cond_dl_fl || ''mL/min'' as cond_dl_fl
	, concat(cond_dl_am, CASE WHEN om.medicine_type = ''1'' THEN md.unit ELSE mdx.unit END) as cond_dl_am
	, om.cond_dl_temp || ''℃'' as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, concat(ROUND(TO_NUMBER(cond_dl_am, ''99999999.99''),1), CASE WHEN om.medicine_type = ''1'' THEN md.unit_second ELSE mdx.unit END) as num_unit
	, null as cond_va_dir
	, null as cond_va
	, null as equip_pnc_cls
    FROM ord_dialysisLiquid om
    LEFT OUTER JOIN mst_medicine md ON (om.medicine_type = ''1'' AND om.medicine_cd = md.medicine_cd and md.is_del = ''0'' and md.is_disp = ''1'')
    LEFT OUTER JOIN mst_medicine_mix mdx ON (om.medicine_type = ''2'' AND om.medicine_cd = mdx.medicine_mix_cd and mdx.is_del = ''0'' and mdx.is_disp = ''1'')
	LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd = mdc.class_cd and mdc.is_del = ''0'' and mdc.is_disp = ''1''
	LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd and kr.is_del = ''0''
	LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
    WHERE (om.medicine_type = ''1'' AND md.class_cd IN (@medIds)) OR (om.medicine_type = ''2'' AND mdx.class_cd IN (@medIds))
	UNION ALL
	--補液
	SELECT 9 as disp_order,om.treat_date,kr.kur_cd,kr.kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id,COALESCE(mdc.class_name,'''') as kind,md.medicine_name AS Name,TO_NUMBER(om.ind_cond_info::json#>>''{22,value}'',''99999999.99'') AS Amount,COALESCE(md.unit,'''') AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry, ''補液'' as class_name, null as Anticoagulant_name, om.ord_no, md.in_hospital_cd_1, md.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, om.ind_cond_info::json#>>''{20, value}'' || ''L'' as cond_rl_am
	, CASE WHEN om.ind_cond_info::json#>>''{21, value}'' = ''0'' THEN ''後補液'' ELSE ''前補液'' END as cond_rl_sel
	, om.ind_cond_info::json#>>''{22, value}'' || CASE WHEN om.medicine_type = ''1'' THEN md.unit ELSE mdx.unit END as cond_rl_use
	, om.ind_cond_info::json#>>''{23, value}'' || ''℃'' as cond_rl_temp
	, om.ind_cond_info::json#>>''{24, value}'' || ''L/min'' as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, ROUND(TO_NUMBER(om.ind_cond_info::json#>>''{22,value}'',''99999999.99''),1) || CASE WHEN om.medicine_type = ''1'' THEN COALESCE(md.unit_second,'''') ELSE COALESCE(mdx.unit,'''') END as num_unit
	, null as cond_va_dir
	, null as cond_va
	, null as equip_pnc_cls
    FROM ord_replenishLiquid om
    LEFT OUTER JOIN mst_medicine md ON (om.medicine_type = ''1'' AND om.medicine_cd = md.medicine_cd and md.is_del = ''0'' and md.is_disp = ''1'')
    LEFT OUTER JOIN mst_medicine_mix mdx ON (om.medicine_type = ''2'' AND om.medicine_cd = mdx.medicine_mix_cd and mdx.is_del = ''0'' and mdx.is_disp = ''1'')
	LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd and mdc.is_del = ''0'' and mdc.is_disp = ''1''
	LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
	LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
    WHERE (om.medicine_type = ''1'' AND md.class_cd IN (@medIds)) OR (om.medicine_type = ''2'' AND mdx.class_cd IN (@medIds))
	UNION ALL
	--抗凝固剤
	SELECT 10 as disp_order, om.treat_date, kr.kur_cd, kr.kur_name, COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd, om.pat_id
	, COALESCE(mdc.class_name,'''') as kind, md.medicine_name AS Name
	, CEIL(((TO_NUMBER(om.ind_cond_info::json#>>''{26,value}'',''99999999.99'')+TO_NUMBER(om.ind_cond_info::json#>>''{28,value}'',''99999999.99'')) / CASE WHEN md.unit_converted_amount=0 THEN 1 ELSE md.unit_converted_amount END) * md.unit_converted_amount_second) AS Amount
	, COALESCE(md.unit,'''') AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry
	, ''抗凝固剤'' as class_name, null as Anticoagulant_name, om.ord_no, md.in_hospital_cd_1, md.in_hospital_cd_2
	, null AS equip_circuit
	, TO_NUMBER(om.ind_cond_info::json#>>''{26,value}'',''99999999.99'') || om.unit as cond_ac_shot
	, TO_NUMBER(om.ind_cond_info::json#>>''{27,value}'',''99999999.99'') || CASE WHEN om.unit IS NULL THEN '''' ELSE om.unit || ''/h'' END as cond_ac_spd
	, TO_NUMBER(om.ind_cond_info::json#>>''{28,value}'',''99999999.99'') || om.unit as cond_ac_dur_total
	, CASE WHEN om.ind_cond_info::json#>>''{29,value}'' = ''1'' THEN ''使用する'' ELSE ''使用しない'' END as cond_ip_use
	, CASE WHEN om.ind_cond_info::json#>>''{30,value}'' = ''1'' THEN ''自動'' ELSE ''手動'' END as cond_ip_start
	, om.ind_cond_info::json#>>''{32,value}'' || ''mL/h'' as cond_ip_spd
	, CASE WHEN om.ind_cond_info::json#>>''{34,value}'' = ''1'' THEN ''自動'' ELSE ''手動'' END as cond_ip_shot_st
	, om.ind_cond_info::json#>>''{31,value}'' || ''mL'' as cond_ip_shot
	, CASE WHEN om.ind_cond_info::json#>>''{35,value}'' = ''1'' THEN ''入'' ELSE ''切'' END as cond_ip_off
	, om.ind_cond_info::json#>>''{36,value}'' || ''分'' as cond_ip_off_tm
	, CASE WHEN om.ind_cond_info::json#>>''{37,value}'' = ''1'' THEN ''入'' ELSE ''切'' END as cond_ip_ok
	, om.ind_cond_info::json#>>''{38,value}'' || ''分'' as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, ROUND(TO_NUMBER(om.ind_cond_info::json#>>''{28,value}'',''99999999.99''),1) || om.unit as num_unit
	, null as cond_va_dir
	, null as cond_va
	, null as equip_pnc_cls
	FROM Anticoagulant om
    LEFT OUTER JOIN mst_medicine md ON (om.medicine_type = ''1'' AND om.medicine_cd = md.medicine_cd and md.is_del = ''0'' and md.is_disp = ''1'')
    LEFT OUTER JOIN mst_medicine_mix mdx ON (om.medicine_type = ''2'' AND om.medicine_cd = mdx.medicine_mix_cd and mdx.is_del = ''0'' and mdx.is_disp = ''1'')
	LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd and mdc.is_del = ''0'' and mdc.is_disp = ''1''
	LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
	LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
    WHERE (om.medicine_type = ''1'' AND md.class_cd IN (@medIds)) OR (om.medicine_type = ''2'' AND mdx.class_cd IN (@medIds))
	UNION ALL
	--投薬(薬剤)
	SELECT 11 as disp_order, om.treat_date, kr.kur_cd, kr.kur_name, COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id
	, COALESCE(mdc.class_name,'''') as kind,md.medicine_name as Name
	, CEIL(((TO_NUMBER(medi ->> ''amount'' ,''99999999.99'')) / CASE WHEN md.unit_converted_amount=0 THEN 1 ELSE md.unit_converted_amount END) / CASE WHEN md.unit_converted_amount_second=0 THEN 1 ELSE md.unit_converted_amount_second END) as Amount
	, COALESCE(md.unit_second, COALESCE(md.unit,'''')) AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry, ''投与薬剤'' as class_name, null as Anticoagulant_name, om.ord_no, md.in_hospital_cd_1, md.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, mt.medicate_timing_name as medi_timing
	, mp.pricedure_name as medi_proc
	, om.amount || COALESCE(md.unit,'''') as num_unit
	, null as cond_va_dir
	, null as cond_va
	, null as equip_pnc_cls
	FROM ord_medi as om
	LEFT OUTER JOIN mst_medicine md ON (om.medicine_type = ''1'' AND om.cd = md.medicine_cd and md.is_del = ''0'' and md.is_disp = ''1'')
	LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd and mdc.is_del = ''0'' and mdc.is_disp = ''1''
	LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
	LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
	LEFT OUTER JOIN mst_medicate_timing mt ON to_number(medi->>''timing_cd'', ''9999999999'') = mt.medicate_timing_cd and mt.is_del = ''0'' and mt.is_disp = ''1''
	LEFT OUTER JOIN mst_procedure mp ON to_number(medi->>''procedure_cd'', ''9999999999'') = mp.procedure_cd and mp.is_del = ''0'' and mp.is_disp = ''1''
    WHERE (om.medicine_type = ''1'' AND md.class_cd IN (@medIds))
    UNION ALL
	--投薬(調製薬剤)
	SELECT 11 as disp_order, om.treat_date, kr.kur_cd, kr.kur_name, COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id
	, COALESCE(mdc.class_name,'''') as kind,md.medicine_name as Name
	, CEIL(((TO_NUMBER(medi ->> ''amount'' ,''99999999.99'')) / CASE WHEN md.unit_converted_amount=0 THEN 1 ELSE md.unit_converted_amount END) / CASE WHEN md.unit_converted_amount_second=0 THEN 1 ELSE md.unit_converted_amount_second END) as Amount
	, COALESCE(md.unit_second, COALESCE(md.unit,'''')) AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry, ''投与薬剤'' as class_name, null as Anticoagulant_name, om.ord_no, md.in_hospital_cd_1, md.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, mt.medicate_timing_name as medi_timing
	, mp.pricedure_name as medi_proc
	, to_number(om.amount, ''9999999999.999'') * to_number(mdx.amount, ''9999999999.999'') || COALESCE(md.unit,'''') as num_unit
	, null as cond_va_dir
	, null as cond_va
	, null as equip_pnc_cls
	FROM ord_medi as om
    LEFT OUTER JOIN (
    SELECT medicine_mix_cd, info->>''cd'' as cd, info->>''amount'' as amount
    FROM  mst_medicine_mix
    cross join lateral
      json_array_elements (mst_medicine_mix.mix_info :: json) info
    WHERE
      mst_medicine_mix.is_del = ''0'' and mst_medicine_mix.is_disp = ''1'' and mst_medicine_mix.class_cd IN (@medIds)) mdx on om.cd = mdx.medicine_mix_cd
    LEFT OUTER JOIN mst_medicine md ON (to_number(mdx.cd,''9999999999'') = md.medicine_cd and md.is_del = ''0'' and md.is_disp = ''1'')
	LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd=mdc.class_cd and mdc.is_del = ''0'' and mdc.is_disp = ''1''
	LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
	LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
	LEFT OUTER JOIN mst_medicate_timing mt ON to_number(medi->>''timing_cd'', ''9999999999'') = mt.medicate_timing_cd and mt.is_del = ''0'' and mt.is_disp = ''1''
	LEFT OUTER JOIN mst_procedure mp ON to_number(medi->>''procedure_cd'', ''9999999999'') = mp.procedure_cd and mp.is_del = ''0'' and mp.is_disp = ''1''
    WHERE om.medicine_type = ''2''
	UNION ALL 
	--医材
	SELECT 12 as disp_order,om.treat_date,kr.kur_cd,kr.kur_name,COALESCE(bd.bed_name,''未登録'') as bed_name,om.ind_bed_cd AS bed_cd,om.pat_id,COALESCE(eqc.class_name,'''') as kind,eq.equipment_name as Name,(TO_NUMBER(eqi ->> ''amount'' ,''99999999.99'')) as Amount,COALESCE(eq.unit,'''') AS Unit
    , null as function_class, null as area, null as ufr, null as koa, null as material, null as wetdry, ''医療材料'' as class_name, null as Anticoagulant_name, om.ord_no, eq.in_hospital_cd_1, eq.in_hospital_cd_2
	, null AS equip_circuit
	, null as cond_ac_shot
	, null as cond_ac_spd
	, null as cond_ac_dur_total
	, null as cond_ip_use
	, null as cond_ip_start
	, null as cond_ip_spd
	, null as cond_ip_shot_st
	, null as cond_ip_shot
	, null as cond_ip_off
	, null as cond_ip_off_tm
	, null as cond_ip_ok
	, null as cond_ip_ok_tm
	, null as cond_dl_fl
	, null as cond_dl_am
	, null as cond_dl_temp
	, null as cond_rl_am
	, null as cond_rl_sel
	, null as cond_rl_use
	, null as cond_rl_temp
	, null as cond_rl_spd
	, null as medi_timing
	, null as medi_proc
	, concat(eqi->>''amount'', eq.unit) as num_unit
	, null as cond_va_dir
	, null as cond_va
	, null as equip_pnc_cls
	FROM ord_main as om CROSS JOIN LATERAL json_array_elements (om.ind_equip_info :: json) eqi
	LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(eqi ->> ''cd'' ,''9999999999'') = eq.equipment_cd and eq.is_del = ''0'' and eq.is_disp = ''1''
	LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd=eqc.class_cd and eqc.is_del = ''0'' and eqc.is_disp = ''1''
	LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd=kr.kur_cd and kr.is_del = ''0''
	LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd=bd.bed_cd and bd.is_del = ''0'' and bd.is_disp = ''1''
	WHERE om.ord_no IN (@ordNos) and om.is_del = ''0''
    AND eq.class_cd IN (@eqIds)
) as EquipmentList
INNER JOIN plan_time on EquipmentList.ord_no=plan_time.ord_no
ORDER BY kur_cd,kur_name,bed_name,pat_id,disp_order,kind)

select 
bd.treat_date,bd.kur_cd,bd.kur_name,bd.bed_name,bd.bed_cd,bd.pat_id,bd.kind,bd.Name
, bd.amount
, bd.unit
, bd.function_class, bd.area, bd.ufr, bd.koa, bd.material, bd.wetdry, bd.disp_order, bd.class_name, bd.anticoagulant_name
, bd.plan_time, bd.cond_dw, bd.cond_tg_wei, bd.cond_tre_nm, bd.cond_bld_fl
, bd.in_hospital_cd_1, bd.in_hospital_cd_2
, bd.equip_circuit
, bd.cond_ac_shot
, bd.cond_ac_spd
, bd.cond_ac_dur_total
, bd.cond_ip_use
, bd.cond_ip_start
, bd.cond_ip_spd
, bd.cond_ip_shot_st
, bd.cond_ip_shot
, bd.cond_ip_off
, bd.cond_ip_off_tm
, bd.cond_ip_ok
, bd.cond_ip_ok_tm
, bd.cond_dl_fl
, bd.cond_dl_am
, bd.cond_dl_temp
, bd.cond_rl_am
, bd.cond_rl_sel
, bd.cond_rl_use
, bd.cond_rl_temp
, bd.cond_rl_spd
, bd.medi_timing
, bd.medi_proc
, bd.num_unit
, bd.cond_va_dir
, bd.cond_va
, bd.equip_pnc_cls,
case
   when count(distinct rbg1.room_bed_group_name) = 0 then ''グループ未登録''
   when count(distinct rbg1.room_bed_group_name) = 1 then (max(rbg1.room_bed_group_name))
   else ''グループ複数選択''
 end as room_bed_group_name_1,
case
   when count(distinct rbg2.room_bed_group_name) = 0 then ''グループ未登録''
   when count(distinct rbg2.room_bed_group_name) = 1 then (max(rbg2.room_bed_group_name))
   else ''グループ複数選択''
 end as room_bed_group_name_2
from EquipmentList_Tmp as bd
LEFT OUTER JOIN mst_room_bed_group_1 as rbg1 ON
rbg1.bed_list::text like ''%'' || bd.bed_cd || ''%''
LEFT OUTER JOIN mst_room_bed_group_2 as rbg2 ON
rbg2.bed_list::text like ''%'' || bd.bed_cd || ''%''
GROUP BY bd.treat_date,bd.kur_cd,bd.kur_name,bd.bed_name,bd.bed_cd,bd.pat_id,bd.kind,bd.Name
, bd.amount
, bd.unit
, bd.function_class, bd.area, bd.ufr, bd.koa, bd.material, bd.wetdry, bd.disp_order, bd.class_name, bd.anticoagulant_name
, bd.plan_time, bd.cond_dw, bd.cond_tg_wei, bd.cond_tre_nm, bd.cond_bld_fl
, bd.in_hospital_cd_1, bd.in_hospital_cd_2
, bd.equip_circuit
, bd.cond_ac_shot
, bd.cond_ac_spd
, bd.cond_ac_dur_total
, bd.cond_ip_use
, bd.cond_ip_start
, bd.cond_ip_spd
, bd.cond_ip_shot_st
, bd.cond_ip_shot
, bd.cond_ip_off
, bd.cond_ip_off_tm
, bd.cond_ip_ok
, bd.cond_ip_ok_tm
, bd.cond_dl_fl
, bd.cond_dl_am
, bd.cond_dl_temp
, bd.cond_rl_am
, bd.cond_rl_sel
, bd.cond_rl_use
, bd.cond_rl_temp
, bd.cond_rl_spd
, bd.medi_timing
, bd.medi_proc
, bd.num_unit
, bd.cond_va_dir
, bd.cond_va
, bd.equip_pnc_cls
ORDER BY pat_id,kur_cd,kur_name,bed_name,disp_order,kind
', 2, '[{"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "kur_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "bed_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200101", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_date", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "disp_order", "data_name": "分類", "data_type": "Integer", "conv_table": [], "data_class": "", "field_name": "disp_order", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "class_name", "data_name": "分類", "data_type": "String", "conv_table": [], "data_class": "物品情報", "field_name": "class_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "plan_time", "data_name": "透析時間", "data_type": "String", "conv_table": [], "data_class": "物品情報", "field_name": "plan_time", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dw", "data_name": "DW", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_dw", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_tg_wei", "data_name": "目標体重", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_tg_wei", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_tre_nm", "data_name": "治療項目", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_tre_nm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_bld_fl", "data_name": "血流量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_bld_fl", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "function_class", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "area", "data_name": "面積", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "area", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "ufr", "data_name": "UFR", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "ufr", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "koa", "data_name": "KOA", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "koa", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "material", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "wetdry", "data_name": "DRYWET", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "wetdry", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "anticoagulant_name", "data_name": "抗凝固剤", "data_type": "String", "conv_table": [], "data_class": "", "field_name": "anticoagulant_name", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "equip_circuit", "data_name": "血液回路", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "equip_circuit", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_shot", "data_name": "ワンショット量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_shot", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_spd", "data_name": "持続速度", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_dur_total", "data_name": "持続総量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_dur_total", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_use", "data_name": "IP使用選択", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ip_use", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_start", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_spd", "data_name": "IP速度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_shot_st", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_shot_st", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_shot", "data_name": "IPワンショット量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_shot", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_off", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_off_tm", "data_name": "IP電源自動切り時間", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_off_tm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_ok", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_ok", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_ok_tm", "data_name": "IP電源OKモニタ切り時間", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_ok_tm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_fl", "data_name": "透析液流量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_fl", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_am", "data_name": "透析液量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_am", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_temp", "data_name": "透析温度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_temp", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_am", "data_name": "補液量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_am", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_sel", "data_name": "補液選択", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_sel", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_use", "data_name": "補液使用数", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_use", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_temp", "data_name": "補液温度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_temp", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_spd", "data_name": "補液速度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "medi_timing", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "medi_timing", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "medi_proc", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "medi_proc", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "1", "can_calc": "0", "data_code": "num_unit", "data_name": "数量・単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "num_unit", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_va_dir", "data_name": "VA方向", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_va_dir", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_va", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_va", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "equip_pnc_cls", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "equip_pnc_cls", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "ベッドグループ1", "can_calc": "", "data_code": "room_bed_group_name_1", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "room_bed_group_name_1", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "透析室名１", "can_calc": "", "data_code": "room_bed_group_name_2", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "room_bed_group_name_2", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}]', '1', '{"applications": [1]}', '{"classes": [8]}', 'ラベル', '2020-03-17 14:17:00', CURRENT_TIMESTAMP, NULL);
