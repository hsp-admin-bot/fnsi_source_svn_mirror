UPDATE "ntss"."sys_data_set" SET "sql" = 'select
  ord.ind_treatment_name as treatment_name,
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
  left join pat_unique as un
  on un.pat_id=ord.pat_id
  left join mst_dialyzer md
  on md.dialyzer_cd = cast(ord.ind_cond_info->''5''->>''value'' as INTEGER)
where
  ord.ord_no = @ordNo
  and un.is_del = ''0''', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 5;
