delete from  sys_data_set where sql_cd in(102,107);
UPDATE "ntss"."sys_data_set" SET "sql" = 'select
  ord.ind_treatment_name as treatment_name,
	
CASE 
      WHEN  ord.ind_dw is null THEN  cast(info ->> ''dw'' :: TEXT as integer)
      ELSE ord.ind_dw
  END AS dw,
  ord.ind_cond_info->''1''->>''value'' as treatment_time,
  ord.ind_cond_info->''2''->>''value_name_1'' as va,
  ord.ind_cond_info->''3''->>''value'' as target_weight,
  ord.ind_cond_info->''4''->>''value'' as water_removal_amount_limit,
  ord.ind_cond_info->''5''->>''value_name_1'' as dialyzer,
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
	left join pat_unique  as  un on   un.pat_id=ord.pat_id	
	cross join 
      json_array_elements (un.physical_info :: json) info
where
  ord.ord_no = @ordNo
  and is_del = ''0''' WHERE "sql_cd" = 5;
UPDATE "ntss"."sys_data_set" SET "sql" = 'SELECT
	rst_treatment_name,
	rst_kur_name,
	rst_bed_name,
	rst_dw,
CASE
	
	WHEN abs(
	to_number (
REPLACE (
( date_trunc ( ''day'', to_timestamp ( ord.treat_date, ''yyyyMMdd hh24:mi:ss'' ) ) - date_trunc ( ''day'', mst.in_hosp_a_startdate ) ) :: text,
	''days'',
	'''' 
	),
	''99999'' 
	) 
	) < abs(
		to_number (
			REPLACE ( ( date_trunc ( ''day'',to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_b_startdate ) ) :: text, ''days'', '''' ),
			''99999'' 
		) 
		) THEN
		mst.in_hospital_cd_a1 ELSE mst.in_hospital_cd_b1 
	END AS rst_trea_in_hospital_cd_1,
CASE
		
		WHEN abs(
			to_number (
				REPLACE (
					( date_trunc ( ''day'', to_timestamp ( ord.treat_date, ''yyyyMMdd hh24:mi:ss'' ) ) - date_trunc ( ''day'', mst.in_hosp_a_startdate ) ) :: text,
					''days'',
					'''' 
				),
				''99999'' 
			) 
			) < abs(
			to_number (
				REPLACE ( ( date_trunc ( ''day'', to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_b_startdate ) ) :: text, ''days'', '''' ),
				''99999'' 
			) 
			) THEN
			mst.in_hospital_cd_a2 ELSE mst.in_hospital_cd_b2 
		END AS rst_trea_in_hospital_cd_2,
	CASE
			
			WHEN abs(
				to_number (
					REPLACE ( ( date_trunc ( ''day'', to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_a_startdate ) ) :: text, ''days'', '''' ),
					''99999'' 
				) 
				) < abs(
				to_number (
					REPLACE ( ( date_trunc ( ''day'', to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_b_startdate ) ) :: text, ''days'', '''' ),
					''99999'' 
				) 
				) THEN
				mst.in_hospital_cd_a3 ELSE mst.in_hospital_cd_b3 
			END AS rst_trea_in_hospital_cd_3,
		CASE
				
				WHEN abs(
					to_number (
						REPLACE ( ( date_trunc ( ''day'', to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_a_startdate ) ) :: text, ''days'', '''' ),
						''99999'' 
					) 
					) < abs(
					to_number (
						REPLACE ( ( date_trunc ( ''day'', to_timestamp(ord.treat_date,''yyyyMMdd hh24:mi:ss'') ) - date_trunc ( ''day'', mst.in_hosp_b_startdate ) ) :: text, ''days'', '''' ),
						''99999'' 
					) 
					) THEN
					mst.in_hospital_cd_a4 ELSE mst.in_hospital_cd_b4 
				END AS rst_trea_in_hospital_cd_4,
				msk.in_hospital_cd_1 AS rst_kur_in_hospital_cd_1,
				msb.in_hospital_cd_1 AS rst_bed_in_hospital_cd_1,
				msb.in_hospital_cd_2 AS rst_bed_in_hospital_cd_2 
			FROM
				ord_main ord
				LEFT JOIN mst_treatment mst ON ( ord.rst_treatment_cd = mst.treatment_cd AND mst.is_del = ''0'' AND mst.is_disp = ''1'' )
				LEFT JOIN mst_kur msk ON ( ord.rst_kur_cd = msk.kur_cd AND msk.is_del = ''0'' )
				LEFT JOIN mst_bed msb ON ( ord.rst_bed_cd = msb.bed_cd AND msb.is_disp = ''1'' AND msb.is_del = ''0'' ) 
			WHERE
				ord.pat_id = @patId 
				AND ord.ord_no = @ordNo 
			AND ord.is_del = ''0'' 
AND ord.rst_dialysis_state <> ''0'';', "detail" = '[{"preview": "テスト治療方法", "can_calc": "0", "data_code": "rst_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_1", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_2", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_3", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_4", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストクール", "can_calc": "0", "data_code": "rst_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_kur_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_kur_in_hospital_cd_1", "data_name": "クール連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_kur_in_hospital_cd_1", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストベッド", "can_calc": "0", "data_code": "rst_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_bed_in_hospital_cd_1", "data_name": "ベッド連携コード１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_in_hospital_cd_1", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_bed_in_hospital_cd_2", "data_name": "ベッド連携コード２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_in_hospital_cd_2", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "rst_dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dw", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 7;


