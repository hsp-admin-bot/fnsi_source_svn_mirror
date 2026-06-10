DELETE FROM "ntss"."sys_data_set" where sql_cd in (127);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (127, 'with machine_tbl as (
  select
    mm.*,
	mmt.machine_type
  from
    mst_machine as mm
  left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    mm.facility_cd = @facilityCd
	and
		mm.machine_no in (@machineNos)
  and
    mm.is_disp = ''1''
  and
    mm.is_del = ''0''
)
, water_survey_type_tbl as (
  select
    survey_type_cd,
    survey_type_name,
    integer_digits,
    decimal_digits
  from
    mst_water_survey_type
  where
    facility_cd = @facilityCd
  and
    is_disp = ''1''
  and
    is_del = ''0''
)
, water_survey_point_select as(
	select
     A.*,ms.index
  from
    mst_water_survey_point A   --テーブル名
    ,(
		select
			mss.facility_cd, ms.*, row_number() over() as index
		from
			mst_selector mss
		cross join lateral jsonb_to_recordset(mss.order_settings->''items'') as ms
		(
			code bigint,
			name text
		)
		where
			facility_cd = @facilityCd
		and
			master_physical_name = ''mst_water_survey_point''
	 ) ms
      where
           A.survey_point_cd = ms.code 
       and
           A.facility_cd = ms.facility_cd
       and
           A.is_del = ''0''
       and
           A.is_disp = ''1''
      order by
           ms.index
)
, water_survey_point_tb as (
  select
    case when mwsp.machine_no is not null then mwsp.machine_no
		else -1 end as machine_no,
    mt.machine_name,
		mt.machine_serial,
		mt.machine_type,
    mwsp.survey_type_cd,
		mwsp.survey_point_cd,
    mwsp.point_name,
		mwsp.in_hospital_cd_1 as point_in_hospital_cd_1,
		mwsp.in_hospital_cd_2 as point_in_hospital_cd_2,
		mwsp.index
  from
    water_survey_point_select as mwsp
      left join machine_tbl as mt
        on mwsp.machine_no = mt.machine_no
  where
    mwsp.facility_cd = @facilityCd
  and
    mwsp.is_disp = ''1''
  and
    mwsp.is_del = ''0''
)
, water_survey_point_tbl as (
  select
    survey_point_cd,
    point_name,
	point_in_hospital_cd_1,
	point_in_hospital_cd_2,
    machine_no,
    machine_name,
	machine_serial,
	machine_type,
    survey_type_cd,
    index
  from
    water_survey_point_tb
  where
    machine_no in (@machineNos)
)
, water_servey_tbl as (
  select
    mws.*,
    survey_data_json ->> ''point_cd'' as point_cd,
    survey_data_json ->> ''plan'' as plan,
    survey_data_json ->> ''time'' as time,
    survey_data_json ->> ''picker'' as picker,
    survey_data_json ->> ''value'' as value,
    survey_data_json ->> ''unit'' as unit,
    survey_data_json ->> ''text'' as text,
    survey_data_json ->> ''inspector'' as inspector,
    survey_data_json ->> ''memo'' as memo
  from
    mnt_water_survey as mws
    CROSS JOIN LATERAL json_array_elements(mws.survey_data ::json) survey_data_json
		LEFT JOIN water_survey_point_tbl as wsp on CAST(wsp.survey_point_cd as TEXT) = survey_data_json ->> ''point_cd''
  where
    facility_cd = @facilityCd
  and
    inspection_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
	and 
		wsp.survey_point_cd is not null	
  and
    is_disp = ''1''
  and
    is_del = ''0''
)
, inspection_date_records as (
  select
    to_char(inspection_date, ''yyyy/mm/dd'') as inspection_date 
  from
    water_servey_tbl
  group by water_servey_tbl.inspection_date
)
, cells as (
  select
    *
    ,inspection_date_records.inspection_date as inspection_date_str
  from
    water_survey_point_tbl, inspection_date_records
	where
		water_survey_point_tbl.machine_no in (@machineNos)
)
, inspection_records as (
  select
    wspt.machine_no as m_no,
    wspt.machine_name as m_name,
    wspt.survey_type_cd as s_t_code,
    wstt.survey_type_name as s_t_name,
    wspt.survey_point_cd as s_p_code,
    wspt.point_name as p_name,
    wst.*,
	case
      when (wst.value <> '''') then 
				(CASE WHEN wst.value::numeric < (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits)) AND LENGTH(TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))) <> wstt.decimal_digits
					THEN (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits))::text
					WHEN wst.value::numeric = (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits)) AND LENGTH(TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))) <> wstt.decimal_digits
					THEN ROUND(wst.value::numeric, wstt.decimal_digits)::text
				WHEN wst.value::numeric >= ROUND(wst.value::numeric, wstt.decimal_digits) AND LENGTH(SPLIT_PART(wst.value, ''.'', 2)) > wstt.decimal_digits
					THEN SPLIT_PART(wst.value, ''.'', 1) || ''.'' || TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))
				ELSE wst.value::text END) 
				|| coalesce(wst.unit, '''') 
				|| (case when (wst.text is not null and wst.text <> ''0'' and wst.text <> '''') then wst.text else '''' end)
      when (wst.memo <> '''' or wst.time <> '''' or CAST(wst.picker AS INTEGER) != 0 or CAST(wst.inspector AS INTEGER) != 0) then ''検査中''
      when (wst.text is not null and wst.text <> ''0'' and wst.text <> '''') then wst.text
      when wst.plan = ''1'' then ''〇''
      else null
    end as result
  from
    water_survey_point_tbl as wspt
      left join water_servey_tbl as wst
         on wst.point_cd = wspt.survey_point_cd ::TEXT
      left join water_survey_type_tbl as wstt
        on wspt.survey_type_cd = wstt.survey_type_cd
)
, disp_order_tbl as (
  select
    one_json->>''code'' as code
    --,one_json->>''name'' as bed_name
    ,json_idx as disp_order
  from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(one_json, json_idx)
  where
    facility_cd = @facilityCd and master_physical_name = ''mst_machine''
)
select a.* from (
	select
		cells.index
		,cells.machine_no
		,cells.machine_name
		,cells.machine_serial
		,cells.machine_type
		,cells.survey_type_cd
		,case
			when (cells.survey_type_cd is not null) then water_survey_type_tbl.survey_type_name
			else null
		end as survey_type_name
		,cells.survey_point_cd
		,cells.point_name
		,cells.point_in_hospital_cd_1
		,cells.point_in_hospital_cd_2
		,cells.inspection_date_str
		,inspection_records.*
	from
		cells
		left outer join inspection_records
			on cells.survey_point_cd = inspection_records.s_p_code
			and cells.inspection_date = to_char(inspection_records.inspection_date, ''yyyy/mm/dd'')
		left outer join disp_order_tbl
			on cells.machine_no::text = disp_order_tbl.code::text
		left outer join water_survey_type_tbl
			on cells.survey_type_cd = water_survey_type_tbl.survey_type_cd
) a ORDER BY ARRAY_POSITION(ARRAY[@machineNos], a.machine_no), a.index, a.survey_type_cd, a.inspection_date_str;
', 2, '[{"preview":"I7012104","can_calc":"0","data_code":"machine_com_format_serial","data_name":"製造番号","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"machine_serial","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"DAB","can_calc":"0","data_code":"machine_name","data_name":"装置名","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"machine_name","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"DCS-27","can_calc":"0","data_code":"machine_type","data_name":"型式","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"machine_type","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"1","can_calc":"0","data_code":"survey_type_cd","data_name":"水質検査種別コード","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"survey_type_cd","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"ET","can_calc":"0","data_code":"survey_type_name","data_name":"水質検査種別名","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"survey_type_name","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"1","can_calc":"0","data_code":"survey_point_cd","data_name":"水質検査箇所コード","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"survey_point_cd","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"B原液タンク(ET)","can_calc":"0","data_code":"point_name","data_name":"水質検査箇所名","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"point_name","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"1","can_calc":"0","data_code":"point_in_hospital_cd_1","data_name":"水質検査箇所連携コード1","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"point_in_hospital_cd_1","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"1","can_calc":"0","data_code":"point_in_hospital_cd_2","data_name":"水質検査箇所連携コード2","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"point_in_hospital_cd_2","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"2025/01/24","can_calc":"0","data_code":"inspection_date_str","data_name":"検査日","data_type":"DateTime","conv_table":[],"data_class":"水質管理","field_name":"inspection_date_str","disp_format":"yyyy/mm/dd","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"200EU/mL未満","can_calc":"0","data_code":"result","data_name":"検査結果","data_type":"string","conv_table":[],"data_class":"水質管理","field_name":"result","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '水質管理：水質管理 @machineNos @facilityCd @fromDate @toDate', '2020-04-02 00:00:00', CURRENT_TIMESTAMP, NULL);
