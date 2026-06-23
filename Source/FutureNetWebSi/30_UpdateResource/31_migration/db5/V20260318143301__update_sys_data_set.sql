DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 152;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (152, 'with mb as (
	select
      bed_cd,
      bed_name,
      in_hospital_cd_1,
      in_hospital_cd_2,
      shunt_position,
      is_infection,
      machine_no
    from
      mst_bed
    where
      facility_cd = @facilityCd
    and is_disp = ''1'' and is_del = ''0'' and machine_no is not null
    and bed_cd in (@bedCds)
)
, mk as (
		select kur_cd, kur_name, kur_start_time from mst_kur where facility_cd = @facilityCd and is_del = ''0''
		and kur_cd in (@kurCds)
)
, treat_date_records as (
		select
    to_char(generate_series, ''yyyymmdd'') as treat_date
		from
    generate_series(date_trunc(''day'', ( @fromDate )::timestamp), date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''1 day'')
)
, sche_cells as (
		select
    *
		from
    mb, mk, treat_date_records
)
, om as (
		select
    ord_main.*,
		pat_main.is_same,
		pat_main.is_same as first_name_is_same,
		pat_main.is_same as pat_name_is_same,
		pat_main.is_infect,
    	mt.device_mode
		from
    ord_main
		left join pat_main
    on pat_main.pat_id = ord_main.pat_id
    LEFT JOIN mst_treatment mt
    ON mt.treatment_cd = ord_main.ind_treatment_cd
		where
    ord_main.facility_cd = @facilityCd
		and
		ord_main.pat_id in (@patIds)
		and
    ord_main.treat_date between to_char(date_trunc(''day'', ( @fromDate )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
		and
    ord_main.is_del = ''0''
)
, bed_disp_order_tbl as (
		select
    one_json->>''code'' as bed_cd
    --,one_json->>''name'' as bed_name
    ,json_idx as bed_disp_order
		from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(one_json, json_idx)
		where
    facility_cd = @facilityCd
		and master_physical_name = ''mst_bed''
)
, kur_disp_order_tbl as (
		select
		one_json->>''code'' as kur_cd
		,json_idx as kur_disp_order
		from
		mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(one_json, json_idx)
		where
		facility_cd = @facilityCd
		and master_physical_name = ''mst_kur''
)
-- 検査依頼の予定有無
, pem as (
  SELECT
    pat_id,
    reg_exam_date
  FROM
    pat_exam_main
  WHERE
    reg_exam_date >= date_trunc(''day'', ( @fromDate )::timestamp)
    and reg_exam_date <  date_trunc(''day'', ( @toDate )::timestamp) + interval ''1 day''
		and facility_cd = @facilityCd
		and pat_id IN (@patIds)
    and is_order = ''1''
		and is_del = ''0''
)
-- 一般撮影の予定有無
, prm as (
  SELECT
    pat_id,
    reg_rad_date
  FROM
    pat_rad_main
  WHERE
    reg_rad_date >= date_trunc(''day'', ( @fromDate )::timestamp)
    and reg_rad_date <  date_trunc(''day'', ( @toDate )::timestamp) + interval ''1 day''
		and facility_cd = @facilityCd
		and pat_id IN (@patIds)
		and is_del = ''0''
)
-- 患者イベントの予定有無
, pe as (
  SELECT
    pat_id,
    event_start_date,
    event_end_date
  FROM
    pat_event
  WHERE
    event_end_date::timestamp >= date_trunc(''day'', ( @fromDate )::timestamp)
    and event_start_date::timestamp <  date_trunc(''day'', ( @toDate )::timestamp) + interval ''1 day''
		and facility_cd = @facilityCd
		and pat_id IN (@patIds)
		and is_del = ''0'' 
)
-- 定期点検の予定有無
, mmm as (
  SELECT
    mmm.machine_no,
    mainte_date
  FROM
    mnt_mainte_main mmm
  INNER JOIN mb ON mb.machine_no = mmm.machine_no
  WHERE
    mainte_date >= date_trunc(''day'', ( @fromDate )::timestamp)
    and mainte_date <  date_trunc(''day'', ( @toDate )::timestamp) + interval ''1 day''
		and facility_cd = @facilityCd
		and mainte_class = ''2''
		and is_disp = ''1''
		and is_del = ''0''
)
-- 水質調査の予定有無
, mws as (
  SELECT
    inspection_date,
    mwsp.machine_no,
    mb.bed_cd
  FROM
    mnt_water_survey mws
  CROSS JOIN LATERAL jsonb_array_elements(mws.survey_data) AS elem
  INNER JOIN mst_water_survey_point mwsp
    ON (elem->>''point_cd'')::int = mwsp.survey_point_cd
  INNER JOIN mst_bed mb
    ON mwsp.machine_no = mb.machine_no
  WHERE
    mws.is_disp = ''1''
    AND mws.is_del = ''0''
    AND mws.facility_cd = @facilityCd
    AND mws.inspection_date >= date_trunc(''day'', ( @fromDate )::timestamp)
    AND mws.inspection_date <  date_trunc(''day'', ( @toDate )::timestamp) + interval ''1 day''
    AND elem->>''value'' IS NOT NULL -- 予定未登録→結果登録→結果削除するとjsonにレコードが残るため除外
)
, all_cells as (
  select
      sche_cells.treat_date
      ,lpad(kur_disp_order::text, 19, ''0'') as kur_disp_order
      ,sche_cells.kur_cd
      ,sche_cells.kur_name
      ,lpad(bed_disp_order::text, 19, ''0'') as bed_disp_order
      ,sche_cells.bed_cd
      ,sche_cells.bed_name
      ,sche_cells.shunt_position
      ,mva.va_direct
      ,sche_cells.machine_no
      ,mm.is_disable
      ,sche_cells.is_infection
      ,om.device_mode
      ,sche_cells.in_hospital_cd_1
      ,sche_cells.in_hospital_cd_2
      ,om.is_same
      ,om.first_name_is_same
      ,om.pat_name_is_same
      ,om.pat_id as pat_last_name_id
      ,om.pat_id as in_out_class
      ,om.pat_id
      
      ,pem.reg_exam_date
      ,CASE
        WHEN pem.reg_exam_date IS NOT NULL THEN 1
        ELSE 0
      END AS EXAM_HAVE
      ,prm.reg_rad_date
      ,CASE
        WHEN prm.reg_rad_date IS NOT NULL THEN 1
        ELSE 0
      END AS RAD_HAVE
      ,pe.event_start_date
      ,pe.event_end_date
      ,CASE
        WHEN pe.event_start_date IS NOT NULL THEN 1
        ELSE 0
      END AS event_have
      ,mmm.mainte_date
      ,CASE
        WHEN mmm.mainte_date IS NOT NULL THEN 1
        ELSE 0
      END AS mainte_have
      ,mws.inspection_date
      ,CASE
        WHEN mws.inspection_date IS NOT NULL THEN 1
        ELSE 0
      END AS inspection_have
      
      ,CASE
        WHEN mva.va_direct IS NULL OR va_direct = '''' OR sche_cells.shunt_position IS NULL THEN 0
        WHEN sche_cells.shunt_position = ''3'' OR mva.va_direct = ''3'' THEN 0
        WHEN mva.va_direct = ''-'' THEN 1
        WHEN sche_cells.shunt_position <> mva.va_direct::smallint THEN 1
        ELSE 0
      END AS va_unmatch
      ,CASE
        WHEN mm.is_disable = ''1'' THEN 1
        WHEN om.device_mode = ''-1'' THEN 1
        WHEN (array[is_support_hd, is_support_ecum, is_support_hdf, is_support_hf, is_support_hd_ho, is_support_ecum_ho, is_support_afbf, is_support_ohdf, is_support_ohf, is_support_blood_purify, is_support_i_hdf])[om.device_mode + 1] = ''0'' THEN 1
        WHEN (array[is_support_hd, is_support_ecum, is_support_hdf, is_support_hf, is_support_hd_ho, is_support_ecum_ho, is_support_afbf, is_support_ohdf, is_support_ohf, is_support_blood_purify, is_support_i_hdf])[om.device_mode + 1] = ''1'' THEN 0
        ELSE 0
      END AS device_modle_unmatch
      ,CASE
        WHEN om.is_infect <> sche_cells.is_infection THEN 1
        ELSE 0
      END AS infect_unmatch
  from
      sche_cells
      left outer join om
      on sche_cells.treat_date = om.treat_date 
      and sche_cells.bed_cd = om.ind_bed_cd
      and sche_cells.kur_cd = om.ind_kur_cd
      left outer join bed_disp_order_tbl
      on sche_cells.bed_cd::text = bed_disp_order_tbl.bed_cd::text
      left outer join kur_disp_order_tbl
      on sche_cells.kur_cd::text = kur_disp_order_tbl.kur_cd::text
      LEFT JOIN mst_va mva
      ON mva.va_cd = om.ind_va_cd
      LEFT JOIN mst_machine mm
      ON mm.machine_no = sche_cells.machine_no
      LEFT JOIN pem
      ON date_trunc(''day'', pem.reg_exam_date::timestamp) = om.treat_date::timestamp AND om.pat_id = pem.pat_id
      LEFT JOIN prm
      ON date_trunc(''day'', prm.reg_rad_date::timestamp) = om.treat_date::timestamp AND om.pat_id = prm.pat_id
      LEFT JOIN pe
      ON om.treat_date::timestamp >= pe.event_start_date::timestamp AND om.treat_date::timestamp <= pe.event_end_date::timestamp AND om.pat_id = pe.pat_id
      LEFT JOIN mmm
      ON date_trunc(''day'', mmm.mainte_date::timestamp) = om.treat_date::timestamp AND sche_cells.machine_no = mmm.machine_no
      LEFT JOIN mws
      ON date_trunc(''day'', mws.inspection_date::timestamp) = om.treat_date::timestamp AND sche_cells.machine_no = mws.machine_no
      ORDER BY sche_cells.treat_date, bed_disp_order, kur_disp_order
)
, all_extend_cells as (
  SELECT
  all_cells.*
    ,GREATEST(va_unmatch, device_modle_unmatch, infect_unmatch) AS is_unmatch
    ,GREATEST(exam_have, rad_have, event_have) AS is_have
    ,GREATEST(mainte_have, inspection_have) AS is_mnt
  FROM
    all_cells
)
SELECT
  all_extend_cells.*
  ,CASE
    WHEN is_have = ''0'' AND is_same = ''0'' THEN 0
    WHEN is_have = ''1'' AND is_same = ''0'' THEN 1
    WHEN is_have = ''0'' AND is_same = ''1'' THEN 2
    WHEN is_have = ''1'' AND is_same = ''1'' THEN 3
    ELSE 0
  END AS first_name_is_have
  ,CASE
    WHEN is_have = ''0'' AND is_same = ''0'' THEN 0
    WHEN is_have = ''1'' AND is_same = ''0'' THEN 1
    WHEN is_have = ''0'' AND is_same = ''1'' THEN 2
    WHEN is_have = ''1'' AND is_same = ''1'' THEN 3
    ELSE 0
  END AS pat_name_is_have
  ,CASE
    WHEN is_unmatch = ''0'' AND is_same = ''0'' THEN 0
    WHEN is_unmatch = ''1'' AND is_same = ''0'' THEN 1
    WHEN is_unmatch = ''0'' AND is_same = ''1'' THEN 2
    WHEN is_unmatch = ''1'' AND is_same = ''1'' THEN 3
    ELSE 0
  END AS first_name_is_unmatch
  ,CASE
    WHEN is_unmatch = ''0'' AND is_same = ''0'' THEN 0
    WHEN is_unmatch = ''1'' AND is_same = ''0'' THEN 1
    WHEN is_unmatch = ''0'' AND is_same = ''1'' THEN 2
    WHEN is_unmatch = ''1'' AND is_same = ''1'' THEN 3
    ELSE 0
  END AS pat_name_is_unmatch
  ,CASE
    WHEN is_same = ''0'' AND is_mnt = ''0'' THEN 0
    WHEN is_same = ''1'' AND is_mnt = ''0'' THEN 1
    WHEN is_same = ''0'' AND is_mnt = ''1'' THEN 2
    WHEN is_same = ''1'' AND is_mnt = ''1'' THEN 3
    ELSE 0
  END AS first_name_is_mnt
  ,CASE
    WHEN is_same = ''0'' AND is_mnt = ''0'' THEN 0
    WHEN is_same = ''1'' AND is_mnt = ''0'' THEN 1
    WHEN is_same = ''0'' AND is_mnt = ''1'' THEN 2
    WHEN is_same = ''1'' AND is_mnt = ''1'' THEN 3
    ELSE 0
  END AS pat_name_is_mnt
  ,CASE
    WHEN is_unmatch = ''0'' AND is_have = ''0'' AND is_same = ''0'' AND is_mnt = ''0'' THEN 0
    
    WHEN is_unmatch = ''1'' AND is_have = ''0'' AND is_same = ''0'' AND is_mnt = ''0'' THEN 1
    WHEN is_unmatch = ''0'' AND is_have = ''1'' AND is_same = ''0'' AND is_mnt = ''0'' THEN 2
    WHEN is_unmatch = ''0'' AND is_have = ''0'' AND is_same = ''1'' AND is_mnt = ''0'' THEN 3
    WHEN is_unmatch = ''0'' AND is_have = ''0'' AND is_same = ''0'' AND is_mnt = ''1'' THEN 4
    
    WHEN is_unmatch = ''1'' AND is_have = ''1'' AND is_same = ''0'' AND is_mnt = ''0'' THEN 5
    WHEN is_unmatch = ''1'' AND is_have = ''0'' AND is_same = ''1'' AND is_mnt = ''0'' THEN 6
    WHEN is_unmatch = ''1'' AND is_have = ''0'' AND is_same = ''0'' AND is_mnt = ''1'' THEN 7
    WHEN is_unmatch = ''0'' AND is_have = ''1'' AND is_same = ''1'' AND is_mnt = ''0'' THEN 8
    WHEN is_unmatch = ''0'' AND is_have = ''1'' AND is_same = ''0'' AND is_mnt = ''1'' THEN 9
    WHEN is_unmatch = ''0'' AND is_have = ''0'' AND is_same = ''1'' AND is_mnt = ''1'' THEN 10
    
    WHEN is_unmatch = ''1'' AND is_have = ''1'' AND is_same = ''1'' AND is_mnt = ''0'' THEN 11
    WHEN is_unmatch = ''1'' AND is_have = ''1'' AND is_same = ''0'' AND is_mnt = ''1'' THEN 12
    WHEN is_unmatch = ''1'' AND is_have = ''0'' AND is_same = ''1'' AND is_mnt = ''1'' THEN 13
    WHEN is_unmatch = ''0'' AND is_have = ''1'' AND is_same = ''1'' AND is_mnt = ''1'' THEN 14
    
    WHEN is_unmatch = ''1'' AND is_have = ''1'' AND is_same = ''1'' AND is_mnt = ''1'' THEN 15
    ELSE 0
  END AS first_name_is_all
  ,CASE
    WHEN is_unmatch = ''0'' AND is_have = ''0'' AND is_same = ''0'' AND is_mnt = ''0'' THEN 0
    
    WHEN is_unmatch = ''1'' AND is_have = ''0'' AND is_same = ''0'' AND is_mnt = ''0'' THEN 1
    WHEN is_unmatch = ''0'' AND is_have = ''1'' AND is_same = ''0'' AND is_mnt = ''0'' THEN 2
    WHEN is_unmatch = ''0'' AND is_have = ''0'' AND is_same = ''1'' AND is_mnt = ''0'' THEN 3
    WHEN is_unmatch = ''0'' AND is_have = ''0'' AND is_same = ''0'' AND is_mnt = ''1'' THEN 4
    
    WHEN is_unmatch = ''1'' AND is_have = ''1'' AND is_same = ''0'' AND is_mnt = ''0'' THEN 5
    WHEN is_unmatch = ''1'' AND is_have = ''0'' AND is_same = ''1'' AND is_mnt = ''0'' THEN 6
    WHEN is_unmatch = ''1'' AND is_have = ''0'' AND is_same = ''0'' AND is_mnt = ''1'' THEN 7
    WHEN is_unmatch = ''0'' AND is_have = ''1'' AND is_same = ''1'' AND is_mnt = ''0'' THEN 8
    WHEN is_unmatch = ''0'' AND is_have = ''1'' AND is_same = ''0'' AND is_mnt = ''1'' THEN 9
    WHEN is_unmatch = ''0'' AND is_have = ''0'' AND is_same = ''1'' AND is_mnt = ''1'' THEN 10
    
    WHEN is_unmatch = ''1'' AND is_have = ''1'' AND is_same = ''1'' AND is_mnt = ''0'' THEN 11
    WHEN is_unmatch = ''1'' AND is_have = ''1'' AND is_same = ''0'' AND is_mnt = ''1'' THEN 12
    WHEN is_unmatch = ''1'' AND is_have = ''0'' AND is_same = ''1'' AND is_mnt = ''1'' THEN 13
    WHEN is_unmatch = ''0'' AND is_have = ''1'' AND is_same = ''1'' AND is_mnt = ''1'' THEN 14
    
    WHEN is_unmatch = ''1'' AND is_have = ''1'' AND is_same = ''1'' AND is_mnt = ''1'' THEN 15
    ELSE 0
  END AS pat_name_is_all
FROM
  all_extend_cells', 2, '[{"preview": "テスト患者姓", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_last_name", "target_var": "@patId"}, "data_code": "pat_last_name", "data_name": "患者名(姓のみ)", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "pat_last_name_id", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者姓*", "can_calc": "0", "data_code": "first_name_is_same", "data_name": "患者名(姓のみ)+同姓同名フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "患者名", "item": "なし"}, {"code": "1", "disp": "患者名*", "item": "あり"}], "data_class": "スケジュール表", "field_name": "first_name_is_same", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "！テスト患者姓*", "can_calc": "0", "data_code": "first_name_is_unmatch", "data_name": "患者名(姓のみ)+不一致", "data_type": "string", "conv_table": [{"code": "0", "disp": "患者名", "item": "不一致無+同姓同名無"}, {"code": "1", "disp": "！患者名", "item": "不一致有+同姓同名無"}, {"code": "2", "disp": "患者名*", "item": "不一致無+同姓同名有"}, {"code": "3", "disp": "！患者名*", "item": "不一致有+同姓同名有"}], "data_class": "スケジュール表", "field_name": "first_name_is_unmatch", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者姓*◆", "can_calc": "0", "data_code": "first_name_is_have", "data_name": "患者名(姓のみ)+他の予定有", "data_type": "string", "conv_table": [{"code": "0", "disp": "患者名", "item": "同姓同名無+他の予定無"}, {"code": "1", "disp": "患者名◆", "item": "同姓同名無+他の予定有"}, {"code": "2", "disp": "患者名*", "item": "同姓同名有+他の予定無"}, {"code": "3", "disp": "患者名*◆", "item": "同姓同名有+他の予定有"}], "data_class": "スケジュール表", "field_name": "first_name_is_have", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者姓*■", "can_calc": "0", "data_code": "first_name_is_mnt", "data_name": "患者名(姓のみ)+定期点検・水質検査予定", "data_type": "string", "conv_table": [{"code": "0", "disp": "患者名", "item": "同姓同名無+定期点検・水質検査予定無"}, {"code": "1", "disp": "患者名*", "item": "同姓同名無+定期点検・水質検査予定有"}, {"code": "2", "disp": "患者名■", "item": "同姓同名有+定期点検・水質検査予定無"}, {"code": "3", "disp": "患者名*■", "item": "同姓同名有+定期点検・水質検査予定有"}], "data_class": "スケジュール表", "field_name": "first_name_is_mnt", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "！テスト患者姓*◆■", "can_calc": "0", "data_code": "first_name_is_all", "data_name": "患者名(姓のみ)+全フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "患者名", "item": "不一致無+同姓同名無+他の予定無+定期点検・水質検査予定無"}, {"code": "1", "disp": "！患者名", "item": "不一致有+同姓同名無+他の予定無+定期点検・水質検査予定無"}, {"code": "2", "disp": "患者名◆", "item": "不一致無+同姓同名無+他の予定有+定期点検・水質検査予定無"}, {"code": "3", "disp": "患者名*", "item": "不一致無+同姓同名有+他の予定無+定期点検・水質検査予定無"}, {"code": "4", "disp": "患者名■", "item": "不一致無+同姓同名無+他の予定無+定期点検・水質検査予定有"}, {"code": "5", "disp": "！患者名◆", "item": "不一致有+同姓同名無+他の予定有+定期点検・水質検査予定無"}, {"code": "6", "disp": "！患者名*", "item": "不一致有+同姓同名有+他の予定無+定期点検・水質検査予定無"}, {"code": "7", "disp": "！患者名■", "item": "不一致有+同姓同名無+他の予定無+定期点検・水質検査予定有"}, {"code": "8", "disp": "患者名*◆", "item": "不一致無+同姓同名有+他の予定有+定期点検・水質検査予定無"}, {"code": "9", "disp": "患者名◆■", "item": "不一致無+同姓同名無+他の予定有+定期点検・水質検査予定有"}, {"code": "10", "disp": "患者名*■", "item": "不一致無+同姓同名有+他の予定無+定期点検・水質検査予定有"}, {"code": "11", "disp": "！患者名*◆", "item": "不一致有+同姓同名有+他の予定有+定期点検・水質検査予定無"}, {"code": "12", "disp": "！患者名◆■", "item": "不一致有+同姓同名無+他の予定有+定期点検・水質検査予定有"}, {"code": "13", "disp": "！患者名*■", "item": "不一致有+同姓同名有+他の予定無+定期点検・水質検査予定有"}, {"code": "14", "disp": "患者名*◆■", "item": "不一致無+同姓同名有+他の予定有+定期点検・水質検査予定有"}, {"code": "15", "disp": "！患者名*◆■", "item": "不一致有+同姓同名有+他の予定有+定期点検・水質検査予定有"}], "data_class": "スケジュール表", "field_name": "first_name_is_all", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "pat_id", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者*", "can_calc": "0", "data_code": "pat_name_is_same", "data_name": "患者名+同姓同名フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "患者名", "item": "なし"}, {"code": "1", "disp": "患者名*", "item": "あり"}], "data_class": "スケジュール表", "field_name": "pat_name_is_same", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "！テスト患者*", "can_calc": "0", "data_code": "pat_name_is_unmatch", "data_name": "患者名+不一致", "data_type": "string", "conv_table": [{"code": "0", "disp": "患者名", "item": "不一致無+同姓同名無"}, {"code": "1", "disp": "！患者名", "item": "不一致有+同姓同名無"}, {"code": "2", "disp": "患者名*", "item": "不一致無+同姓同名有"}, {"code": "3", "disp": "！患者名*", "item": "不一致有+同姓同名有"}], "data_class": "スケジュール表", "field_name": "pat_name_is_unmatch", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者*◆", "can_calc": "0", "data_code": "pat_name_is_have", "data_name": "患者名+他の予定有", "data_type": "string", "conv_table": [{"code": "0", "disp": "患者名", "item": "同姓同名無+他の予定無"}, {"code": "1", "disp": "患者名◆", "item": "同姓同名無+他の予定有"}, {"code": "2", "disp": "患者名*", "item": "同姓同名有+他の予定無"}, {"code": "3", "disp": "患者名*◆", "item": "同姓同名有+他の予定有"}], "data_class": "スケジュール表", "field_name": "pat_name_is_have", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者*■", "can_calc": "0", "data_code": "pat_name_is_mnt", "data_name": "患者名+定期点検・水質検査予定", "data_type": "string", "conv_table": [{"code": "0", "disp": "患者名", "item": "同姓同名無+定期点検・水質検査予定無"}, {"code": "1", "disp": "患者名*", "item": "同姓同名無+定期点検・水質検査予定有"}, {"code": "2", "disp": "患者名■", "item": "同姓同名有+定期点検・水質検査予定無"}, {"code": "3", "disp": "患者名*■", "item": "同姓同名有+定期点検・水質検査予定有"}], "data_class": "スケジュール表", "field_name": "pat_name_is_mnt", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "！テスト患者*◆■", "can_calc": "0", "data_code": "pat_name_is_all", "data_name": "患者名+全フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "患者名", "item": "不一致無+同姓同名無+他の予定無+定期点検・水質検査予定無"}, {"code": "1", "disp": "！患者名", "item": "不一致有+同姓同名無+他の予定無+定期点検・水質検査予定無"}, {"code": "2", "disp": "患者名◆", "item": "不一致無+同姓同名無+他の予定有+定期点検・水質検査予定無"}, {"code": "3", "disp": "患者名*", "item": "不一致無+同姓同名有+他の予定無+定期点検・水質検査予定無"}, {"code": "4", "disp": "患者名■", "item": "不一致無+同姓同名無+他の予定無+定期点検・水質検査予定有"}, {"code": "5", "disp": "！患者名◆", "item": "不一致有+同姓同名無+他の予定有+定期点検・水質検査予定無"}, {"code": "6", "disp": "！患者名*", "item": "不一致有+同姓同名有+他の予定無+定期点検・水質検査予定無"}, {"code": "7", "disp": "！患者名■", "item": "不一致有+同姓同名無+他の予定無+定期点検・水質検査予定有"}, {"code": "8", "disp": "患者名*◆", "item": "不一致無+同姓同名有+他の予定有+定期点検・水質検査予定無"}, {"code": "9", "disp": "患者名◆■", "item": "不一致無+同姓同名無+他の予定有+定期点検・水質検査予定有"}, {"code": "10", "disp": "患者名*■", "item": "不一致無+同姓同名有+他の予定無+定期点検・水質検査予定有"}, {"code": "11", "disp": "！患者名*◆", "item": "不一致有+同姓同名有+他の予定有+定期点検・水質検査予定無"}, {"code": "12", "disp": "！患者名◆■", "item": "不一致有+同姓同名無+他の予定有+定期点検・水質検査予定有"}, {"code": "13", "disp": "！患者名*■", "item": "不一致有+同姓同名有+他の予定無+定期点検・水質検査予定有"}, {"code": "14", "disp": "患者名*◆■", "item": "不一致無+同姓同名有+他の予定有+定期点検・水質検査予定有"}, {"code": "15", "disp": "！患者名*◆■", "item": "不一致有+同姓同名有+他の予定有+定期点検・水質検査予定有"}], "data_class": "スケジュール表", "field_name": "pat_name_is_all", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "in_out_class", "target_var": "@patId"}, "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}, {"code": "2", "disp": "死亡", "item": "死亡"}, {"code": "3", "disp": "(不在)", "item": "(不在)"}], "data_class": "スケジュール表", "field_name": "in_out_class", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0000000000000000010", "can_calc": "0", "data_code": "bed_disp_order", "data_name": "ベッド表示順", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_disp_order", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "bed_cd", "data_name": "ベッドコード", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_cd", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストベッド０１", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "連携コード1", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "連携コード2", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/04/07", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "スケジュール表", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "kur_cd", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "kur_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '２次元スケジュール表 @facilityCd @fromdate @todate @patIds @kurCds @bedCds', '2021-05-10 16:40:02', CURRENT_TIMESTAMP, NULL);
