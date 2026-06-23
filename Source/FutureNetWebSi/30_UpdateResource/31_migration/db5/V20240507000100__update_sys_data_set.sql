DELETE FROM "ntss"."sys_data_set" where sql_cd in (5,10,31,208,209);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (5, 'with b AS (
    select ord_main.* from ord_main
     where 	
-- 		 rst_dialysis_state between ''1'' and ''5''and
	   ord_no = @ordNo
     and
       is_del = ''0''
), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
),g as (
select
-- 終了予定
b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
-- 終了予測
CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS ind_end_date_time
-- 透析開始
, b.rst_start_date
-- 透析終了
, b.rst_end_date
, b.ord_no
from  b left join e on b.ord_no = e.ord_no left join f on b.ord_no = f.ord_no)
select g.*,
  case when ord.rst_dialysis_state <> ''0'' then ord.ind_treatment_name else mt.treatment_name end as treatment_name,
  CASE
      WHEN  ord.ind_dw is null THEN  cast((
        select
          pi->>''dw'' as dw
        from
          json_array_elements(un.physical_info::json) as pi
        where
          pi->>''indicator_start_date'' <= ord.treat_date
        order by
          pi->>''indicator_start_date'' desc,
          pi->>''ctl_no'' desc
        limit 1
      ) :: TEXT as FLOAT)
      ELSE ord.ind_dw
  END AS dw,
  ord.ind_cond_info->''1''->>''value'' as treatment_time,
  ord.ind_cond_info->''2''->>''value_name_1'' as va,
  ord.ind_cond_info->''3''->>''value'' as target_weight,
  ord.ind_cond_info->''4''->>''value'' as water_removal_amount_limit,
  md.model_number as dialyzer,
  ord.ind_cond_info->''6''->>''value_name_1'' as adsorption_column,
  ord.ind_cond_info->''7''->>''value_name_1'' as primary_film,
  ord.ind_cond_info->''8''->>''value_name_1'' as secondary_film,
  ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  CASE ord.ind_cond_info->''12''->>''value''
      WHEN ''1'' THEN ''有り''
      WHEN ''0'' THEN ''無し''
      ELSE null
  END AS single_needle,
  ord.ind_cond_info->''13''->>''value'' as blood_circuit,
  ord.ind_cond_info->''14''->>''value'' as blood_flow,
  ord.ind_cond_info->''15''->>''value_name_1'' as dialysate,
  ord.ind_cond_info->''16''->>''value'' as dialysate_flow_rate,
  ord.ind_cond_info->''17''->>''value'' as dialysate_amount,
  ord.ind_cond_info->''17''->>''unit'' as dialysate_amount_unit,
  ord.ind_cond_info->''18''->>''value'' as dialysate_temperature,
  ord.ind_cond_info->''19''->>''value_name_1'' as fluid_replacement,
  ord.ind_cond_info->''20''->>''value'' as fluid_replacement_amount,
  CASE ord.ind_cond_info->''21''->>''value''
      WHEN ''1'' THEN ''前補液''
      WHEN ''0'' THEN ''後補液''
      ELSE null
  END AS fluid_replacement_timing,
  ord.ind_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  ord.ind_cond_info->''22''->>''unit'' as fluid_replacement_use_count_unit,
  ord.ind_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  ord.ind_cond_info->''24''->>''value'' as fluid_replacement_speed,
  ord.ind_cond_info->''25''->>''value_name_1'' as anti_coagulant,
  ord.ind_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  ord.ind_cond_info->''26''->>''unit'' as anti_coagulant_one_shot_amount_unit,
  ord.ind_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  ord.ind_cond_info->''27''->>''unit'' as anti_coagulant_sustained_speed_unit,
  ord.ind_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  ord.ind_cond_info->''28''->>''unit'' as anti_coagulant_sustained_amount_unit,
  CASE ord.ind_cond_info->''29''->>''value''
      WHEN ''1'' THEN ''使用する''
      WHEN ''0'' THEN ''使用しない''
      ELSE null
  END AS ip,
  CASE ord.ind_cond_info->''30''->>''value''
      WHEN ''0'' THEN ''手動''
      WHEN ''1'' THEN ''自動''
      ELSE null
  END AS ip_start,
  ord.ind_cond_info->''31''->>''value'' as ip_one_short_amount,
  ord.ind_cond_info->''32''->>''value'' as ip_speed,
  ord.ind_cond_info->''33''->>''value'' as ip_speed_max,
  CASE ord.ind_cond_info->''34''->>''value''
      WHEN ''1'' THEN ''使用する''
      WHEN ''0'' THEN ''使用しない''
      ELSE null
  END AS auto_one_shot,
  CASE ord.ind_cond_info->''35''->>''value''
      WHEN ''1'' THEN ''入''
      WHEN ''0'' THEN ''切''
      ELSE null
  END AS ip_auto_off,
  ord.ind_cond_info->''36''->>''value'' as ip_auto_off_time,
  CASE ord.ind_cond_info->''37''->>''value''
      WHEN ''1'' THEN ''入''
      WHEN ''0'' THEN ''切''
      ELSE null
  END AS ip_monitor_auto_off,
  ord.ind_cond_info->''38''->>''value'' as ip_monitor_auto_off_time
from
  ord_main as ord
	left JOIN mst_treatment mt on mt.treatment_cd = ord.ind_treatment_cd 
  left join pat_unique as un
  on un.pat_id=ord.pat_id
  left join mst_dialyzer md
  on md.dialyzer_cd = cast(ord.ind_cond_info->''5''->>''value'' as INTEGER)
	left join g
	on ord.ord_no=g.ord_no
where
  ord.ord_no = @ordNo
  and un.is_del = ''0''', 2, '[{"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dw", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "treatment_time", "field_name": "treatment_time"}, {"data_code": "va", "field_name": "va"}, {"data_code": "target_weight", "field_name": "target_weight"}, {"data_code": "water_removal_amount_limit", "field_name": "water_removal_amount_limit"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "adsorption_column", "field_name": "adsorption_column"}, {"data_code": "primary_film", "field_name": "primary_film"}, {"data_code": "secondary_film", "field_name": "secondary_film"}, {"data_code": "puncture_needle_a", "field_name": "puncture_needle_a"}, {"data_code": "puncture_needle_v", "field_name": "puncture_needle_v"}, {"data_code": "puncture_needle_sn", "field_name": "puncture_needle_sn"}, {"data_code": "single_needle", "field_name": "single_needle"}, {"data_code": "blood_circuit", "field_name": "blood_circuit"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "dialysate", "field_name": "dialysate"}, {"data_code": "dialysate_flow_rate", "field_name": "dialysate_flow_rate"}, {"data_code": "dialysate_amount", "field_name": "dialysate_amount"}, {"data_code": "dialysate_amount_unit", "field_name": "dialysate_amount_unit"}, {"data_code": "dialysate_temperature", "field_name": "dialysate_temperature"}, {"data_code": "fluid_replacement", "field_name": "fluid_replacement"}, {"data_code": "fluid_replacement_amount", "field_name": "fluid_replacement_amount"}, {"data_code": "fluid_replacement_timing", "field_name": "fluid_replacement_timing"}, {"data_code": "fluid_replacement_use_count", "field_name": "fluid_replacement_use_count"}, {"data_code": "fluid_replacement_use_count_unit", "field_name": "fluid_replacement_use_count_unit"}, {"data_code": "fluid_replacement_temperature", "field_name": "fluid_replacement_temperature"}, {"data_code": "fluid_replacement_speed", "field_name": "fluid_replacement_speed"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "anti_coagulant_one_shot_amount_unit", "field_name": "anti_coagulant_one_shot_amount_unit"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_sustained_amount_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "ip", "field_name": "ip"}, {"data_code": "ip_start", "field_name": "ip_start"}, {"data_code": "ip_one_short_amount", "field_name": "ip_one_short_amount"}, {"data_code": "ip_speed", "field_name": "ip_speed"}, {"data_code": "ip_speed_max", "field_name": "ip_speed_max"}, {"data_code": "auto_one_shot", "field_name": "auto_one_shot"}, {"data_code": "ip_auto_off", "field_name": "ip_auto_off"}, {"data_code": "ip_auto_off_time", "field_name": "ip_auto_off_time"}, {"data_code": "ip_monitor_auto_off", "field_name": "ip_monitor_auto_off"}, {"data_code": "ip_monitor_auto_off_time", "field_name": "ip_monitor_auto_off_time"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：透析条件@ordNo 使用', '2019-06-17 14:45:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10, 'WITH x AS (
	SELECT
		om.*,
		save.supplies_source_class,
		save.supplies_class,
		save.ind_rst_class,
		save.supplies_cd,
		save.receipt_value,
		save.ind_rst_value,
		save.medicine_mix_cd,
		TO_NUMBER( save.supplies_cd, ''9999999999'' ) supplies_cd_n,
		kr.kur_cd,
		kr.kur_name,
		bd.bed_name
	FROM
		ord_main AS om
		INNER JOIN ord_material_save AS save ON ( om.ord_no = save.supplies_base_no AND om.facility_cd = save.facility_cd AND save.ind_rst_class = ''1'' )
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNo )
		AND om.is_del = ''0''
	) SELECT
	to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
	kur_cd,
	kur_name,
	bed_name,
	pat_id,
	kind,
	NAME,
	SUM ( Amount ) AS amount,
	unit,
	in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4,
	pat_id AS pat_id_to_name
FROM
	(
	SELECT
		1 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
		dz.model_number AS NAME,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			1 ELSE NULL
		END AS Amount,
		'''' AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_dialyzer AS dz ON ( x.supplies_cd_n = dz.dialyzer_cd AND dz.is_del = ''0'' AND dz.is_disp = ''1'' )
		AND dz.dialyzer_cd IN ( @diaIds )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''01''
		AND x.ind_rst_class = ''1'' UNION ALL--吸着カラム
	SELECT
		2 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''02''
		AND x.ind_rst_class = ''1'' UNION ALL--1次膜
	SELECT
		3 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''03''
		AND x.ind_rst_class = ''1'' UNION ALL--2次膜
	SELECT
		4 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''04''
		AND x.ind_rst_class = ''1'' UNION ALL--穿刺針(A針)
	SELECT
		5 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON (
			eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			AND eqc.class_cd IN ( @eqIds )
		)
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''06''
		AND x.ind_rst_class = ''1'' UNION ALL--穿刺針(V針)
	SELECT
		5 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''07''
		AND x.ind_rst_class = ''1'' UNION ALL--穿刺針(SN)
	SELECT
		6 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''05''
		AND x.ind_rst_class = ''1'' UNION ALL--血液回路
	SELECT
		7 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''00''
		AND x.ind_rst_class = ''1'' UNION ALL--透析液
	SELECT
		8 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  CAST ( x.ind_rst_value AS DECIMAL )  ELSE  CAST ( x.receipt_value  AS DECIMAL ) END  AS Amount,
		CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  COALESCE ( md.unit, '''' )  ELSE  COALESCE ( md.unit_second, '''' )  END AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_medicine AS md ON (
			CAST ( x.supplies_cd AS DECIMAL ) = md.medicine_cd
			AND md.is_del = ''0''
			AND md.is_disp = ''1''
			AND md.class_cd IN ( @medIds )
		)
		LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''08''
		AND x.ind_rst_class = ''1'' UNION ALL--補液
	SELECT
		9 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  CAST ( x.ind_rst_value AS DECIMAL )  ELSE  CAST ( x.receipt_value  AS DECIMAL ) END  AS Amount,
		CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  COALESCE ( md.unit, '''' )  ELSE  COALESCE ( md.unit_second, '''' )  END AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_medicine AS md ON (
			x.supplies_cd_n = md.medicine_cd
			AND md.is_del = ''0''
			AND md.is_disp = ''1''
			AND md.class_cd IN ( @medIds )
		)
		LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''09''
		AND x.ind_rst_class = ''1'' UNION ALL--抗凝固剤
	SELECT
		10 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		CEIL (
			(
				( CAST ( x.ind_rst_value AS DECIMAL ) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
				) * md.unit_converted_amount_second
			) AS Amount,
			COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_medicine AS md ON (
				x.supplies_cd_n = md.medicine_cd
				AND md.is_del = ''0''
				AND md.is_disp = ''1''
				AND md.class_cd IN ( @medIds )
			)
			LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
		WHERE
			x.supplies_source_class = ''0''
			AND x.supplies_class = ''10''
			AND x.ind_rst_class = ''1'' UNION ALL--抗凝固剤調製薬剤
		SELECT
			10 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
		CASE

				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
			END AS kind,
			mdx.medicine_mix_name AS NAME,
			CAST ( x.ind_rst_value AS DECIMAL ) AS Amount,
			COALESCE ( mdx.unit, '''' ) AS Unit,
			mdx.in_hospital_cd_1,
			mdx.in_hospital_cd_2,
			mdx.in_hospital_cd_3,
			NULL AS in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_medicine_mix AS mdx ON mdx.medicine_mix_cd = TO_NUMBER( x.medicine_mix_cd, ''999999999999'' )
			LEFT OUTER JOIN mst_medicine_class AS mdc ON ( mdx.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
		WHERE
			x.supplies_source_class = ''0''
			AND x.supplies_class = ''17''
			AND x.ind_rst_class = ''1'' UNION ALL--投薬
		SELECT
			11 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
		CASE

				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
			END AS kind,
			md.medicine_name AS NAME,
			-- CAST ( COALESCE ( NULLIF ( regexp_replace( x.receipt_value, ''[^0-9.]+'', '''', ''g'' ), '''' ), ''0'' ) AS DECIMAL ) AS Amount,
			CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  CAST ( x.ind_rst_value AS DECIMAL )  ELSE  CAST ( x.receipt_value  AS DECIMAL ) END  AS Amount,
      CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  COALESCE ( md.unit, '''' )  ELSE  COALESCE ( md.unit_second, '''' )  END AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_medicine AS md ON TO_NUMBER( x.supplies_cd, ''99999999'' ) = md.medicine_cd
			AND md.is_del = ''0''
			AND md.is_disp = ''1''
			AND md.class_cd IN ( @medIds )
			LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
		WHERE
			x.supplies_source_class = ''1''
			AND x.supplies_class = ''12''
			AND x.ind_rst_class = ''1'' UNION ALL--投薬調製薬剤
		SELECT
			11 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
		CASE

				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
			END AS kind,
			md.medicine_mix_name AS NAME,
			CAST ( x.ind_rst_value AS DECIMAL )  AS Amount,
-- 			CAST ( COALESCE ( NULLIF ( regexp_replace( x.receipt_value, ''[^0-9.]+'', '''', ''g'' ), '''' ), ''0'' ) AS DECIMAL ) AS Amount,
			COALESCE ( md.unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			NULL AS in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_medicine_mix AS md ON ( TO_NUMBER( x.medicine_mix_cd, ''9999999999'' ) = md.medicine_mix_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds ))
			LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
		WHERE
			x.supplies_source_class = ''1''
			AND x.supplies_class = ''13''
			AND x.ind_rst_class = ''1'' UNION ALL--医材
		SELECT
			12 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
		CASE

				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
			END AS kind,
			eq.equipment_name AS NAME,
			CAST ( COALESCE ( NULLIF ( regexp_replace( x.receipt_value, ''[^0-9.]+'', '''', ''g'' ), '''' ), ''0'' ) AS DECIMAL ) AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_equipment AS eq ON x.supplies_cd_n = eq.equipment_cd
			AND eq.class_cd IN ( @eqIds )
			LEFT JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
		WHERE
			x.facility_cd = x.facility_cd
			AND x.supplies_source_class = ''2''
			AND x.ind_rst_class = ''1''
		) AS EquipmentList
	GROUP BY
		treat_date,
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
		disp_order,
		kind,
		NAME,
		Unit,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4
-- 	HAVING
-- 		SUM ( Amount ) > 0
	ORDER BY
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
	disp_order,
	kind;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id_to_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "医材・薬剤", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト医材・薬剤1", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド)', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (31, 'with  pat_facility as (
  select facility_cd
  from
    pat_exam_main
  where  
    pat_id =  @patId limit 1
),
infection_order AS (
  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order 
  from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
  where
    facility_cd =  (select facility_cd from pat_facility )
    and master_physical_name = ''mst_exam_item''
)
select
  info->>''item_cd'' as item_cd,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  info->>''item_name'' as item_name,
  info->>''result'' as result,
  info->>''unit'' as unit,
  info->>''freememo'' as freememo,
  p.result_exam_date as result_exam_date,
  p.reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd,
  info->>''upper'' as upper,
  info->>''lower'' as lower
from (
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id = @patId
    and m.result_exam_date < date_trunc(''day'', @fromDate ::timestamp) + ''1 days''
    and m.result_exam_date >= (date_trunc(''day'', @fromDate ::timestamp) - interval ''1 year'')
    order by m.result_exam_date desc
  ) as p
  cross join lateral
    json_array_elements (p.exam_result_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and item.is_del = ''0'' and item.is_disp =''1''
  left  join  infection_order as inf  on  info->>''item_cd''=inf.infection_cd
order by
  infection_cd_order,reg_exam_date
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日以前)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査結果(指定日以前) @patId @date 使用', '2020-03-25 18:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (209, 'with input_params_expand as
(SELECT event_start_date,json_info ->>''name'' as data_pic_name,json_info ->>''file_path'' as data1_pic1_file_path,pat_event_cd
from (
SELECT pat_event_cd,event_start_date,info->>''result_value'' resul_json

FROM pat_event 
CROSS JOIN LATERAL json_array_elements ( result_params ::json ) info
where is_del = ''0''
    and use_type = 1 
		and pat_id = @patId
		and (info ->>''format_class'') = ''2'') a
		 CROSS JOIN LATERAL json_array_elements ( resul_json :: json ) json_info)
 , input_params_expand_5 as (
SELECT event_start_date,info->>''result_value'' resul_json,pat_event_cd
FROM pat_event 
CROSS JOIN LATERAL json_array_elements ( result_params ::json ) info
where is_del = ''0''
    and use_type = 1 
		and pat_id = @patId
		and (info ->>''format_class'') = ''5''
 )
, order_main as
(
  select
    treat_date,COALESCE ( ord.rst_cond_info -> ''2'' ->> ''value_name_1'', '''' ) as va
  from
    ord_main ord
  where 
	ord.pat_id = @patId
	and ord.treat_date between to_char(date_trunc(''day'', (@fromDate

 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', (@toDate

 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
)
select * from ((select a.*,parms_5.resul_json from input_params_expand a 
INNER JOIN order_main on order_main.va =a.data_pic_name 
LEFT JOIN input_params_expand_5 parms_5 on parms_5.pat_event_cd = a.pat_event_cd
where a.data_pic_name<>'''' 
and order_main.treat_date = a.event_start_date ORDER BY a.event_start_date desc)
 UNION ALL
(select a.*,parms_5.resul_json from input_params_expand as a 
INNER JOIN order_main on order_main.va =a.data_pic_name 
LEFT JOIN input_params_expand_5 parms_5 on parms_5.pat_event_cd = a.pat_event_cd
where a.data_pic_name<>'''' and a.event_start_date < to_char(date_trunc(''day'', @fromDate::timestamp), ''yyyymmdd'') ORDER BY a.event_start_date desc)
) b 
LIMIT 1', 2, '[{"preview": "2011/05/20", "can_calc": "0", "data_code": "event_start_date", "data_name": "開始日時", "data_type": "DateTime", "conv_table": [], "data_class": "VA情報", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/20", "can_calc": "0", "data_code": "make_start_date", "data_name": "造設日", "data_type": "DateTime", "conv_table": [], "data_class": "VA情報", "field_name": "make_start_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic1_file_path", "data_name": "画像", "data_type": "byte[]", "conv_table": [], "data_class": "VA情報", "field_name": "data1_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', 'VA情報 増設日 画像(実績)', '2023-04-23 09:37:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (208, 'with input_params_expand as
(SELECT event_start_date,json_info ->>''name'' as data_pic_name,json_info ->>''file_path'' as data1_pic1_file_path,pat_event_cd
from (
SELECT pat_event_cd,event_start_date,info->>''result_value'' resul_json

FROM pat_event 
CROSS JOIN LATERAL json_array_elements ( result_params ::json ) info
where is_del = ''0''
    and use_type = 1 
		and pat_id = @patId

		and (info ->>''format_class'') = ''2'') a
		 CROSS JOIN LATERAL json_array_elements ( resul_json :: json ) json_info)
, input_params_expand_5 as (
SELECT event_start_date,info->>''result_value'' resul_json,pat_event_cd

FROM pat_event 
CROSS JOIN LATERAL json_array_elements ( result_params ::json ) info
where is_del = ''0''
    and use_type = 1 
		and pat_id = @patId
		and (info ->>''format_class'') = ''5''
 )
, order_main as
(
  select
    treat_date,
		case when ord.rst_dialysis_state = ''0'' then mst_va.va_name else COALESCE ( ord.ind_cond_info -> ''2'' ->> ''value_name_1'', '''' ) end  as va
  from
    ord_main ord
		left join mst_va on mst_va.va_cd = ( ord.ind_cond_info -> ''2'' ->> ''value'')::INTEGER
  where 
	ord.pat_id = @patId

 
	and ord.treat_date between to_char(date_trunc(''day'', (@fromDate

 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', (@toDate

 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
)
select * from ((select a.*,parms_5.resul_json as make_start_date  from input_params_expand a 
INNER JOIN order_main on order_main.va =a.data_pic_name 
LEFT JOIN input_params_expand_5 parms_5 on parms_5.pat_event_cd = a.pat_event_cd
where a.data_pic_name<>'''' 
and order_main.treat_date = a.event_start_date ORDER BY a.event_start_date desc)
 UNION ALL
(select a.*,parms_5.resul_json as make_start_date from input_params_expand as a 
INNER JOIN order_main on order_main.va =a.data_pic_name 
LEFT JOIN input_params_expand_5 parms_5 on parms_5.pat_event_cd = a.pat_event_cd
where a.data_pic_name<>'''' and a.event_start_date < to_char(date_trunc(''day'', @fromDate::timestamp), ''yyyymmdd'') ORDER BY a.event_start_date desc)
) b 
LIMIT 1', 2, '[{"preview": "2011/05/20", "can_calc": "0", "data_code": "event_start_date", "data_name": "開始日時", "data_type": "DateTime", "conv_table": [], "data_class": "VA情報", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic1_file_path", "data_name": "画像", "data_type": "byte[]", "conv_table": [], "data_class": "VA情報", "field_name": "data1_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/20", "can_calc": "0", "data_code": "make_start_date", "data_name": "造設日", "data_type": "DateTime", "conv_table": [], "data_class": "VA情報", "field_name": "make_start_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', 'VA情報 増設日 画像(指示)', '2023-04-23 09:37:00', CURRENT_TIMESTAMP, NULL);
