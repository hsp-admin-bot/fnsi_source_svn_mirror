DELETE FROM "ntss"."sys_data_set" where sql_cd in (7,120,121,122,123,124,125,126,171,178,180,181,182,183,184,185,186);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7, 'SELECT
	rst_treatment_name,
	rst_kur_name,
	ord.ord_no,
COALESCE (
NULLIF(
CASE
WHEN treat_week = ''1'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Mon''->>''user_id''
WHEN treat_week = ''2'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Tues''->>''user_id''
WHEN treat_week = ''3'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Wednes''->>''user_id''
WHEN treat_week = ''4'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Thurs''->>''user_id''
WHEN treat_week = ''5'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Fri''->>''user_id''
WHEN treat_week = ''6'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Satur''->>''user_id''
WHEN treat_week = ''7'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''Sun''->>''user_id''
END,''''), 
NULLIF(((SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = rst_kur_cd) ->''data''->0->''All''->>''user_id''),''''),
NULLIF((SELECT "value" FROM mst_facility_setting  WHERE facility_cd = @facilityCd AND facility_setting_no = ''1025''),''0''),'''')
AS full_time_doctor,
	rst_bed_name,
	rst_dw,
	case 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a1 	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_a_startdate) then mst.in_hospital_cd_b1 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_b_startdate) is null then mst.in_hospital_cd_a1	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_a_startdate) is null then mst.in_hospital_cd_b1
		when date_trunc(''day'', mst.in_hosp_b_startdate) < mst.in_hosp_a_startdate and date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_a1
		when mst.in_hosp_a_startdate < date_trunc(''day'', mst.in_hosp_b_startdate) and date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_b1	
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a1
		else ''''
	end as rst_trea_in_hospital_cd_1,	
	case 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a2 	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_a_startdate) then mst.in_hospital_cd_b2 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_b_startdate) is null then mst.in_hospital_cd_a2	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_a_startdate) is null then mst.in_hospital_cd_b2
		when date_trunc(''day'', mst.in_hosp_b_startdate) < mst.in_hosp_a_startdate and date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_a2
		when mst.in_hosp_a_startdate < date_trunc(''day'', mst.in_hosp_b_startdate) and date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_b2	
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a2
		else ''''
	end as rst_trea_in_hospital_cd_2,	
	case 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a3 	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_a_startdate) then mst.in_hospital_cd_b3 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_b_startdate) is null then mst.in_hospital_cd_a3	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_a_startdate) is null then mst.in_hospital_cd_b3
		when date_trunc(''day'', mst.in_hosp_b_startdate) < mst.in_hosp_a_startdate and date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_a3
		when mst.in_hosp_a_startdate < date_trunc(''day'', mst.in_hosp_b_startdate) and date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_b3	
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a3
		else ''''
	end as rst_trea_in_hospital_cd_3,	
	case 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a4	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst.in_hosp_a_startdate) then mst.in_hospital_cd_b4 	
		when date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_b_startdate) is null then mst.in_hospital_cd_a4	
		when date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst.in_hosp_a_startdate) is null then mst.in_hospital_cd_b4
		when date_trunc(''day'', mst.in_hosp_b_startdate) < mst.in_hosp_a_startdate and date_trunc(''day'', mst.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_a4
		when mst.in_hosp_a_startdate < date_trunc(''day'', mst.in_hosp_b_startdate) and date_trunc(''day'', mst.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst.in_hospital_cd_b4	
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst.in_hosp_b_startdate) then mst.in_hospital_cd_a4
		else ''''
	end as rst_trea_in_hospital_cd_4,	
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
  AND ord.rst_dialysis_state <> ''0'';', 2, '[{"preview": "テスト治療方法", "can_calc": "0", "data_code": "rst_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_1", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_2", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_3", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_trea_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_trea_in_hospital_cd_4", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストクール", "can_calc": "0", "data_code": "rst_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_kur_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_kur_in_hospital_cd_1", "data_name": "クール連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_kur_in_hospital_cd_1", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "常勤医", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "full_time_doctor", "data_name": "常勤医", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "full_time_doctor", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストベッド", "can_calc": "0", "data_code": "rst_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_bed_in_hospital_cd_1", "data_name": "ベッド連携コード１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_in_hospital_cd_1", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "rst_bed_in_hospital_cd_2", "data_name": "ベッド連携コード２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_bed_in_hospital_cd_2", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "rst_dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dw", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', NULL, '2019-09-17 11:32:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (120, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 2
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1

  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''2'') as tmp
;
', 2, '[{"preview": "シャント音", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "良好", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "狭窄", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "拍動", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "閉塞", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト2 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (121, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 3
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1

  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''3'') as tmp
;
', 2, '[{"preview": "透析開始直後", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "動脈側脱血", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈圧", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側返血", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "警報機能確認", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路の状態", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺部の状態", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "投与量・速度確認", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト3 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (122, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 4
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1

  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''4'') as tmp
;
', 2, '[{"preview": "透析中", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "一般状態の確認", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺部の確認", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路の状態", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "エアートラップ液面", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "凝血", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固薬注入量", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液流量の確認", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト4 @ordNo 使用', '2020-03-31 23:59:59',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (123, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 5
)

select
  @ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1

  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''5'') as tmp
;
', 2, '[{"preview": "透析終了直前", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水完了", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11:47", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療時間", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11:47", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "生殖残量", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11:47", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト5 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (124, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 6
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1

  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''6'') as tmp
;
', 2, '[{"preview": "終業時点検", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析終了後", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水誤差", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "液漏れ", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "異音", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "異臭", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外観点検", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "機器動作", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "警報の有無", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト6 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (125, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 7
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1

  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''7'') as tmp
;
', 2, '[{"preview": "", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト7 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (126, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 8
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1

  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''8'') as tmp
;
', 2, '[{"preview": "", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト8 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (171, 'select
  @ordNo AS ord_no,
  occur_date
  ,to_number(monitor_data->>''90'', ''999'') as bp_high
  ,to_number(monitor_data->>''91'', ''999'') as bp_low
  ,to_number(monitor_data->>''92'', ''999'') as bp_ave
  ,to_number(monitor_data->>''93'', ''999'') as pulse
  ,to_number(monitor_data->>''94'', ''999'') as body_temperature
  ,to_number(monitor_data->>''-1'', ''999'') as blood_glucose_level
from
  mni_monitor
where
  ord_no = @ordNo and data_type in (0, 2, 4) and is_del = ''0''
	ORDER BY occur_date DESC
;', 2, '[{"preview": "130", "can_calc": "0", "data_code": "bp_high", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "bp_high", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "88", "can_calc": "0", "data_code": "bp_low", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "bp_low", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "bp_ave", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "bp_ave", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:02", "can_calc": "0", "data_code": "occur_date", "data_name": "測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "バイタル情報", "field_name": "occur_date", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "66", "can_calc": "0", "data_code": "pulse", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "pulse", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "body_temperature", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "body_temperature", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "110.0", "can_calc": "0", "data_code": "blood_glucose_level", "data_name": "血糖値", "data_type": "decimal", "conv_table": [], "data_class": "バイタル情報", "field_name": "blood_glucose_level", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：バイタル情報 @ordNo 使用', '2021-08-05 13:30:00',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (178, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 1
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''1'') as tmp
;', 2, '[{"preview": "始業時点検", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液浄化器", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析条件", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "回路", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "医療材料リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "接続", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "洗浄", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "クレンメ状態", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "気泡除去", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "カプラ向き", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "液面レベル", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "監視装置状態", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針、固定テープ", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:14", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：チェックリスト1 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (180, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 2
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''2'') as tmp
;
', 2, '[{"preview": "シャント音", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "良好", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "狭窄", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "拍動", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "閉塞", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:15", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：チェックリスト2 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (181, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 3
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''3'') as tmp
;
', 2, '[{"preview": "透析開始直後", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "動脈側脱血", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈圧", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側返血", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "警報機能確認", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路の状態", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺部の状態", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "投与量・速度確認", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:45", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：チェックリスト3 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (182, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 4
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''4'') as tmp
;
', 2, '[{"preview": "透析中", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "一般状態の確認", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺部の確認", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路の状態", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "エアートラップ液面", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "凝血", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固薬注入量", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液流量の確認", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:21", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：チェックリスト4 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (183, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 5
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''5'') as tmp
;
', 2, '[{"preview": "透析終了直前", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水完了", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11:47", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療時間", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11:47", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "生殖残量", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11:47", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：チェックリスト5 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (184, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 6
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''6'') as tmp
;
', 2, '[{"preview": "終業時点検", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析終了後", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水誤差", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "液漏れ", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "異音", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "異臭", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外観点検", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "機器動作", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "警報の有無", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:52", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：チェックリスト6 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (185, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 7
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''7'') as tmp
;
', 2, '[{"preview": "", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：チェックリスト7 @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (186, 'with checklist_cd_record as (
  select
    rst_checklist_info->>''checklist_cd'' as cd
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
  order by occur_date limit 1
)
, setting_tbl as (
  select
    checklist_settings
  from
    mst_checklist
  where
    checklist_cd::text in (select cd from checklist_cd_record)
    and is_del = ''0''
    and is_disp = ''1''
)
, setting_tbl_expand as
(
  select
    checklist_setting
    ,json_idx
  from
    setting_tbl
    cross join lateral jsonb_array_elements(checklist_settings) with ordinality as tmp(checklist_setting, json_idx)
)
, row_to_col_tbl as
(
  select
    array_agg(is_check order by cast(rst_checklist_info->>''item_number'' as integer)) as is_checks
    ,array_agg(rst_class order by cast(rst_checklist_info->>''item_number'' as integer)) as rst_classes
    ,array_agg(list_cd order by cast(rst_checklist_info->>''item_number'' as integer)) as list_cds
    ,array_agg(func_class order by cast(rst_checklist_info->>''item_number'' as integer)) as func_classes
    ,array_agg(rst_checklist_info order by cast(rst_checklist_info->>''item_number'' as integer)) as check_infos
    ,array_agg(reg_staff_info order by cast(rst_checklist_info->>''item_number'' as integer)) as staff_infos
    ,array_agg(occur_date order by cast(rst_checklist_info->>''item_number'' as integer)) as occur_dates
  from
    ord_checklist
  where
    is_del = ''0''
    and is_disp = ''1''
    and ord_no = @ordNo
    and list_cd = 8
)

select
@ordNo AS ord_no,
  checklist_setting->>''list_cd'' as list_cd
  ,checklist_setting->>''list_name'' as list_name
  ,checklist_setting->>''dialysis_prog_name'' as dialysis_prog_name

  ,check_infos[1]->>''name'' as item_name_1
  ,case
    when checklist_setting->''funclist''->0->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->0->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_1
  ,checklist_setting->''funclist''->0->>''list_name'' as class_code_name_1
  ,is_checks[1] as is_check_1
  ,staff_infos[1]->>''reg_staff_cd'' as reg_staff_cd_1
  ,occur_dates[1] as occur_date_1
  
  ,check_infos[2]->>''name'' as item_name_2
  ,case
    when checklist_setting->''funclist''->1->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->1->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_2
  ,checklist_setting->''funclist''->1->>''list_name'' as class_code_name_2
  ,is_checks[2] as is_check_2
  ,staff_infos[2]->>''reg_staff_cd'' as reg_staff_cd_2
  ,occur_dates[2] as occur_date_2

  ,check_infos[3]->>''name'' as item_name_3
  ,case
    when checklist_setting->''funclist''->2->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->2->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_3
  ,checklist_setting->''funclist''->2->>''list_name'' as class_code_name_3
  ,is_checks[3] as is_check_3
  ,staff_infos[3]->>''reg_staff_cd'' as reg_staff_cd_3
  ,occur_dates[3] as occur_date_3

  ,check_infos[4]->>''name'' as item_name_4
  ,case
    when checklist_setting->''funclist''->3->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->3->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_4
  ,checklist_setting->''funclist''->3->>''list_name'' as class_code_name_4
  ,is_checks[4] as is_check_4
  ,staff_infos[4]->>''reg_staff_cd'' as reg_staff_cd_4
  ,occur_dates[4] as occur_date_4

  ,check_infos[5]->>''name'' as item_name_5
  ,case
    when checklist_setting->''funclist''->4->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->4->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_5
  ,checklist_setting->''funclist''->4->>''list_name'' as class_code_name_5
  ,is_checks[5] as is_check_5
  ,staff_infos[5]->>''reg_staff_cd'' as reg_staff_cd_5
  ,occur_dates[5] as occur_date_5

  ,check_infos[6]->>''name'' as item_name_6
  ,case
    when checklist_setting->''funclist''->5->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->5->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_6
  ,checklist_setting->''funclist''->5->>''list_name'' as class_code_name_6
  ,is_checks[6] as is_check_6
  ,staff_infos[6]->>''reg_staff_cd'' as reg_staff_cd_6
  ,occur_dates[6] as occur_date_6

  ,check_infos[7]->>''name'' as item_name_7
  ,case
    when checklist_setting->''funclist''->6->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->6->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_7
  ,checklist_setting->''funclist''->6->>''list_name'' as class_code_name_7
  ,is_checks[7] as is_check_7
  ,staff_infos[7]->>''reg_staff_cd'' as reg_staff_cd_7
  ,occur_dates[7] as occur_date_7

  ,check_infos[8]->>''name'' as item_name_8
  ,case
    when checklist_setting->''funclist''->7->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->7->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_8
  ,checklist_setting->''funclist''->7->>''list_name'' as class_code_name_8
  ,is_checks[8] as is_check_8
  ,staff_infos[8]->>''reg_staff_cd'' as reg_staff_cd_8
  ,occur_dates[8] as occur_date_8

  ,check_infos[9]->>''name'' as item_name_9
  ,case
    when checklist_setting->''funclist''->8->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->8->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_9
  ,checklist_setting->''funclist''->8->>''list_name'' as class_code_name_9
  ,is_checks[9] as is_check_9
  ,staff_infos[9]->>''reg_staff_cd'' as reg_staff_cd_9
  ,occur_dates[9] as occur_date_9

  ,check_infos[10]->>''name'' as item_name_10
  ,case
    when checklist_setting->''funclist''->9->>''func_class'' = ''1'' then ''治療条件''
    when checklist_setting->''funclist''->9->>''func_class'' = ''2'' then ''医療材料''
    else ''通常リスト''
  end as func_code_name_10
  ,checklist_setting->''funclist''->9->>''list_name'' as class_code_name_10
  ,is_checks[10] as is_check_10
  ,staff_infos[10]->>''reg_staff_cd'' as reg_staff_cd_10
  ,occur_dates[10] as occur_date_10
from
  row_to_col_tbl cross join (select * from setting_tbl_expand where checklist_setting->>''list_cd'' = ''8'') as tmp
;
', 2, '[{"preview": "", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "list_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "透析工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_1", "data_name": "項目1名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "func_code_name_1", "data_name": "項目1機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_1", "data_name": "項目1分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_1", "data_name": "項目1チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_1", "data_name": "項目1チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_1", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_1", "data_name": "項目1チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_2", "data_name": "項目2名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_2", "data_name": "項目2機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_2", "data_name": "項目2分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_2", "data_name": "項目2チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_2", "data_name": "項目2チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_2", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_2", "data_name": "項目2チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_3", "data_name": "項目3名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_3", "data_name": "項目3機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_3", "data_name": "項目3分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_3", "data_name": "項目3チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士３", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_3", "data_name": "項目3チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_3", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_3", "data_name": "項目3チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_4", "data_name": "項目4名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_4", "data_name": "項目4機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_4", "data_name": "項目4分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_4", "data_name": "項目4チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士４", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_4", "data_name": "項目4チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_4", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_4", "data_name": "項目4チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_5", "data_name": "項目5名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_5", "data_name": "項目5機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_5", "data_name": "項目5分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_5", "data_name": "項目5チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士５", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_5", "data_name": "項目5チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_5", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_5", "data_name": "項目5チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_5", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_6", "data_name": "項目6名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_6", "data_name": "項目6機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_6", "data_name": "項目6分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_6", "data_name": "項目6チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士６", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_6", "data_name": "項目6チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_6", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_6", "data_name": "項目6チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_6", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_7", "data_name": "項目7名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_7", "data_name": "項目7機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_7", "data_name": "項目7分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_7", "data_name": "項目7チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士７", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_7", "data_name": "項目7チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_7", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_7", "data_name": "項目7チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_7", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_8", "data_name": "項目8名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_8", "data_name": "項目8機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_8", "data_name": "項目8分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_8", "data_name": "項目8チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士８", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_8", "data_name": "項目8チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_8", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_8", "data_name": "項目8チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_8", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_9", "data_name": "項目9名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_9", "data_name": "項目9機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_9", "data_name": "項目9分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_9", "data_name": "項目9チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士９", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_9", "data_name": "項目9チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_9", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_9", "data_name": "項目9チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_9", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "item_name_10", "data_name": "項目10名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常リスト", "can_calc": "0", "data_code": "func_code_name_10", "data_name": "項目10機能コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "func_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "class_code_name_10", "data_name": "項目10分類コード名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "class_code_name_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "□", "can_calc": "0", "data_code": "is_check_10", "data_name": "項目10チェック", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１０", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "reg_staff_cd_10", "data_name": "項目10チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_cd_10", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "occur_date_10", "data_name": "項目10チェック日時", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date_10", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：チェックリスト8 @ordNo 使用', '2021-08-05 13:30:00', '2024-07-29 12:16:27.858', NULL);
