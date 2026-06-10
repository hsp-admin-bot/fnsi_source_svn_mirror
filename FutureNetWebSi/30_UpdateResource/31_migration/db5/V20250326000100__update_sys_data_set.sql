DELETE FROM "ntss"."sys_data_set" where sql_cd in (5);
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
      WHEN ord.rst_dialysis_state = ''0'' THEN cast((
        select
          pi->>''dw'' as dw
        from
          json_array_elements(un.physical_info::json) as pi
        where
          to_char(date_trunc(''day'',(pi->>''exam_date'')::TIMESTAMP),''yyyyMMdd'') <= ord.treat_date
					and pi->>''dw'' is not null
        order by
          to_char(date_trunc(''day'',(pi->>''exam_date'')::TIMESTAMP),''yyyyMMdd'') desc,
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
  CASE
    WHEN (ord.ind_cond_info->''26''->>''unit'') IS NOT NULL 
    THEN ord.ind_cond_info->''26''->>''unit''
    WHEN (ord.ind_cond_info->''25''->>''medicine_type'') = ''1'' 
    THEN medicine.unit
    ELSE medicineMix.unit
  END AS anti_coagulant_one_shot_amount_unit,
  ord.ind_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  CASE
    WHEN (ord.ind_cond_info->''27''->>''unit'') IS NOT NULL 
    THEN ord.ind_cond_info->''27''->>''unit''
    WHEN (ord.ind_cond_info->''25''->>''medicine_type'') = ''1'' 
    THEN medicine.unit||''/h''
    ELSE medicineMix.unit||''/h''
  END AS anti_coagulant_sustained_speed_unit,
  ord.ind_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  CASE
    WHEN (ord.ind_cond_info->''28''->>''unit'') IS NOT NULL 
    THEN ord.ind_cond_info->''28''->>''unit''
    WHEN (ord.ind_cond_info->''25''->>''medicine_type'') = ''1'' 
    THEN medicine.unit
    ELSE medicineMix.unit
  END AS anti_coagulant_sustained_amount_unit,
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
	left join mst_medicine as  medicine on medicine.medicine_cd = cast(ord.ind_cond_info->''25''->>''value'' as INTEGER)
	left join mst_medicine_mix as  medicineMix on medicineMix.medicine_mix_cd = cast(ord.ind_cond_info->''25''->>''value'' as INTEGER)
where
  ord.ord_no = @ordNo
  and un.is_del = ''0''', 2, '[{"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dw", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "treatment_time", "field_name": "treatment_time"}, {"data_code": "va", "field_name": "va"}, {"data_code": "target_weight", "field_name": "target_weight"}, {"data_code": "water_removal_amount_limit", "field_name": "water_removal_amount_limit"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "adsorption_column", "field_name": "adsorption_column"}, {"data_code": "primary_film", "field_name": "primary_film"}, {"data_code": "secondary_film", "field_name": "secondary_film"}, {"data_code": "puncture_needle_a", "field_name": "puncture_needle_a"}, {"data_code": "puncture_needle_v", "field_name": "puncture_needle_v"}, {"data_code": "puncture_needle_sn", "field_name": "puncture_needle_sn"}, {"data_code": "single_needle", "field_name": "single_needle"}, {"data_code": "blood_circuit", "field_name": "blood_circuit"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "dialysate", "field_name": "dialysate"}, {"data_code": "dialysate_flow_rate", "field_name": "dialysate_flow_rate"}, {"data_code": "dialysate_amount", "field_name": "dialysate_amount"}, {"data_code": "dialysate_amount_unit", "field_name": "dialysate_amount_unit"}, {"data_code": "dialysate_temperature", "field_name": "dialysate_temperature"}, {"data_code": "fluid_replacement", "field_name": "fluid_replacement"}, {"data_code": "fluid_replacement_amount", "field_name": "fluid_replacement_amount"}, {"data_code": "fluid_replacement_timing", "field_name": "fluid_replacement_timing"}, {"data_code": "fluid_replacement_use_count", "field_name": "fluid_replacement_use_count"}, {"data_code": "fluid_replacement_use_count_unit", "field_name": "fluid_replacement_use_count_unit"}, {"data_code": "fluid_replacement_temperature", "field_name": "fluid_replacement_temperature"}, {"data_code": "fluid_replacement_speed", "field_name": "fluid_replacement_speed"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "anti_coagulant_one_shot_amount_unit", "field_name": "anti_coagulant_one_shot_amount_unit"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_sustained_amount_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"data_code": "ip", "field_name": "ip"}, {"data_code": "ip_start", "field_name": "ip_start"}, {"data_code": "ip_one_short_amount", "field_name": "ip_one_short_amount"}, {"data_code": "ip_speed", "field_name": "ip_speed"}, {"data_code": "ip_speed_max", "field_name": "ip_speed_max"}, {"data_code": "auto_one_shot", "field_name": "auto_one_shot"}, {"data_code": "ip_auto_off", "field_name": "ip_auto_off"}, {"data_code": "ip_auto_off_time", "field_name": "ip_auto_off_time"}, {"data_code": "ip_monitor_auto_off", "field_name": "ip_monitor_auto_off"}, {"data_code": "ip_monitor_auto_off_time", "field_name": "ip_monitor_auto_off_time"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：透析条件@ordNo 使用', '2019-06-17 14:45:00', CURRENT_TIMESTAMP, NULL);
