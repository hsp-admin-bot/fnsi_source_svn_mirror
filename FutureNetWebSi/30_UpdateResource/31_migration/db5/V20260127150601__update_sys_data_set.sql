DELETE FROM "ntss"."sys_data_set" where sql_cd in (109, 111);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (109, 'with
machine_tbl as (
  select
    mm.*,
    mmt.machine_type,
    bed.bed_name
  from
    mst_machine as mm
	LEFT JOIN mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
	LEFT JOIN mst_bed as bed on mm.machine_no = bed.machine_no and mm.facility_cd = bed.facility_cd
  where
    mm.machine_no in ( @machineNos )
  and
    is_disp =''1''
  and
    is_del = ''0''
)
, layout_order AS (
  select
    one_json ->> ''code'' as layout_cd
    , json_idx as layout_order 
	from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_mainte_layout''
)
, category_order AS (
  select
    one_json ->> ''code'' as category_cd
    , json_idx as category_order 
	from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_mainte_category''
)
-- 予定
, mainte_layout_tbl as (
  select
    la.layout_order AS mainte_layout_index,
    *
  from
    mst_mainte_layout AS m
	LEFT JOIN layout_order AS la ON (la.layout_cd::text = m.mainte_layout_cd::text)
  where
    facility_cd = @facilityCd
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY la.layout_order ASC	
)
, mainte_layout_work as (
  select
    mainte_layout_tbl.mainte_layout_cd,
    mainte_layout_tbl.edition_no,
		mainte_layout_tbl.layout_name,
		mainte_category_idx,
    category_info::json->>''cd'' AS mainte_category_cd,
		category_info::json->>''isDisp'' AS mainte_category_isDisp
  from
    mainte_layout_tbl
      cross join lateral jsonb_array_elements_text(detail_info_1)
        with ordinality as tmp(category_info, mainte_category_idx)
)
, mainte_category_tbl as (
  select
    *
  from
    mst_mainte_category AS m
	LEFT JOIN category_order AS la ON (la.category_cd::text = m.mainte_category_cd::text)
  where
    facility_cd = @facilityCd
	and
    mainte_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY la.category_order ASC	
)
, mainte_category_work as (
  select
    mainte_category_tbl.mainte_category_cd,
    mainte_category_tbl.edition_no,
    mainte_category_tbl.category_name,
    mainte_detail_idx,
    detail_info::json->>''code'' AS mainte_detail_cd,
		detail_info::json->>''isDisp'' AS mainte_detail_isDisp
  from
    mainte_category_tbl
      cross join lateral jsonb_array_elements_text(detail)
        with ordinality as tmp(detail_info, mainte_detail_idx)
)
, mainte_detail_tbl as (
  select
    mmd.*,

		mcw.mainte_detail_idx,
    mcw.edition_no as mainte_category_edition,
    mcw.category_name,

    mlw.mainte_category_idx,
    mlw.mainte_layout_cd,
    mlw.edition_no as mainte_layout_edition,
		mlw.layout_name
  from
    mst_mainte_detail as mmd
      inner join mainte_category_work as mcw
        on mcw.mainte_detail_cd::text = mmd.mainte_detail_cd::text
      inner join mainte_layout_work as mlw
        on mlw.mainte_category_cd::text = mcw.mainte_category_cd::text
  where
    mmd.facility_cd = @facilityCd
	and
    mmd.mainte_class = ''1''
  and
    mmd.is_disp = ''1''
  and
    mmd.is_del = ''0''
)
-- 実績
, mainte_layout_hst as (
  select
    *
  from
    mst_mainte_layout_hst AS m
	LEFT JOIN layout_order AS la ON (la.layout_cd::text = m.mainte_layout_cd::text)
  where
    facility_cd = @facilityCd
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY la.layout_order ASC
)
, mainte_category_hst as (
  select
    *
  from
    mst_mainte_category_hst AS m
	LEFT JOIN category_order AS la ON (la.category_cd::text = m.mainte_category_cd::text)
  where
    facility_cd = @facilityCd
	and
    mainte_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY la.category_order ASC
)
, mainte_detail_hst as (
  select
    *
  from
    mst_mainte_detail_hst
  where
    facility_cd = @facilityCd
	and
    mainte_class = ''1''	
  and
    is_disp = ''1''
  and
    is_del = ''0''
)
, mainte_work as (
  select
    *
  from
    mnt_mainte_main
  where
    facility_cd = @facilityCd
  and    
    machine_no in ( @machineNos )
  and    
    mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  and
    mainte_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY mainte_date	
)
, mainte_main_detail_hst as (
  select
    mainte_no,
    json_idx as mainte_detail_idx,
    info->>''detail_cd'' as detail_cd,
    info->>''detail_edi'' as edition,
    info->>''judge'' as judge,
    info->>''comment'' as comment,
    info->>''user_id'' as user_id,
    info->>''date'' as date,
    info->>''cate_cd'' as cate_cd,
    info->>''cate_edi'' as cate_edi
  from
    mainte_work as mt
      cross join lateral jsonb_array_elements(detail)
        with ordinality as tmp(info, json_idx)
)
, mainte_main_category_hst as (
  select
    mainte_no,
    json_idx as mainte_category_idx,
    info->>''mainteCategoryCd'' as category_cd,
    info->>''editionNo'' as edition
  from
    mainte_work as mt
      cross join lateral jsonb_array_elements(mainte_category_cd)
        with ordinality as tmp(info, json_idx)
)
, machine_mainte_layout_all AS (
	SELECT
		mt.machine_no,
		mt.machine_serial,
		mt.machine_type,
		mt.machine_name,
		mt.facility_cd,
		mt.bed_name,
		mt.com_format_cd,
		
		mlt.mainte_layout_index,
		mlt.mainte_layout_cd, 
		mlt.layout_name,
		mlt.edition_no
	FROM
		machine_tbl as mt
	cross join mainte_layout_tbl as mlt
)
, mainte_hst as (
  select
		mt.machine_no,
		mt.machine_serial,
		mt.machine_type,
		mt.machine_name,
		mt.facility_cd,
		mt.bed_name,
		mt.com_format_cd,

		mt.mainte_layout_cd,
		mt.layout_name,
		mt.edition_no AS mainte_layout_edition,
		
    mw.mainte_no,
    mw.mainte_class,
    mw.rec_no,
    mw.mainte_date,
    mw.checker_id_1,
    mw.checker_id_2,
    mw.mainte_ans_1,
    to_char(mw.up_date, ''YYYY/MM/DD'') as up_date,

    mmdh.mainte_detail_idx,
    mmdh.detail_cd as mainte_detail_cd,
    mmdh.edition as mainte_detail_edition,
    mmdh.judge,
    mmdh.comment,
    mmdh.user_id,
    mmdh.date,

    mdh.mainte_content_1,
    mdh.mainte_content_2,
    mdh.mainte_content_3,

    mg.group_name as group_name,
   
		mmch.category_cd,
    mmch.mainte_category_idx,
		mdh.mainte_category_cd,
    mch.edition_no as mainte_category_edition,
    mch.category_name
  from
     machine_mainte_layout_all as mt
	left join mainte_work mw
		on mw.machine_no = mt.machine_no
		and mw.mainte_layout_cd = mt.mainte_layout_cd
	left join mst_mainte_layout_group as mg 
		on mg.mainte_layout_group_cd = mw.mainte_layout_group_cd
		and mg.facility_cd = mw.facility_cd	
  left join mainte_main_detail_hst as mmdh
        on mw.mainte_no = mmdh.mainte_no
	left join mainte_detail_hst as mdh
		on mmdh.detail_cd = mdh.mainte_detail_cd::text and mmdh.edition = mdh.edition_no::text
	left join mainte_main_category_hst as mmch
		on  mmdh.mainte_no = mmch.mainte_no
		and mmdh.cate_cd = mmch.category_cd::text and mmdh.cate_edi = mmch.edition::text
	left join mainte_category_hst as mch
		on mmch.category_cd::text = mch.mainte_category_cd::text and mmch.edition = mch.edition_no::text
	ORDER BY ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), mt.mainte_layout_index, mw.mainte_date, mmch.mainte_category_idx, mmdh.mainte_detail_idx
)
select * from mainte_hst
', 2, '[{"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_serial", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "com_format_cd", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "bed_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_type", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_no", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細含む）", "field_name": "mainte_ans_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "group_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "点検レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_layout_cd", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "layout_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "judge", "data_name": "合否", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細含む）", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "comment", "data_name": "点検コメント", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "category_cd", "data_name": "点検カテゴリコード", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "category_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検見出し", "can_calc": "0", "data_code": "category_name", "data_name": "点検見出し", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検対象", "can_calc": "0", "data_code": "mainte_content_1", "data_name": "点検対象", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検基準", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "点検基準", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検者", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "user_id", "data_name": "点検者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "user_id", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/17", "can_calc": "0", "data_code": "date", "data_name": "個別点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "date", "disp_format": "yyyy/mm/dd", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "checker_id_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "up_date", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置保守：日常点検詳細 @machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (111, 'with 
machine_tbl as (
	SELECT
		mm.machine_no,
		mm.machine_name,
		mm.machine_serial,
		mm.machine_type_cd,
		mmt.machine_type,
		mm.com_format_cd,
		bed.bed_name
	FROM
		mst_machine as mm
		LEFT JOIN mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
		LEFT JOIN mst_bed as bed on mm.machine_no = bed.machine_no and mm.facility_cd = bed.facility_cd
	WHERE
		mm.machine_no in (@machineNos)
	AND
		mm.facility_cd = @facilityCd
	AND
		mm.is_disp =''1''
	AND
		mm.is_del = ''0''
)
, mainte_work as (
	SELECT
		mainte_no,
		mainte_layout_group_cd,
		mainte_layout_group_edition,
		mainte_layout_cd,
		mainte_layout_edition,
		rec_no,
		mainte_date,
		checker_id_1,
		checker_id_2,
		machine_no,
		mainte_ans_1,
		mainte_comment_1,
		detail_info ->> ''tableIndex'' AS tabIndex,
    CAST(detail_info ->> ''cate_cd'' AS INTEGER) AS mainte_category_cd,
		CAST(detail_info ->> ''cate_edi'' AS INTEGER) AS mainte_category_edition,
    CAST(detail_info ->> ''detail_cd'' AS INTEGER) AS mainte_detail_cd,
		CAST(detail_info ->> ''edition'' AS INTEGER) AS mainte_detail_edition,
		detail_info ->> ''judge'' as judge,
		detail_info ->> ''comment'' as comment,
		detail_info ->> ''user_id'' as user_id,
		CAST(detail_info ->> ''date'' AS TIMESTAMP) as date,
		up_date
	FROM
		mnt_mainte_main
	CROSS JOIN LATERAL jsonb_array_elements(detail) outer_arr
	CROSS JOIN LATERAL jsonb_array_elements(outer_arr) detail_info
	WHERE
		machine_no in (@machineNos)
	AND
		facility_cd = @facilityCd
	AND
		mainte_date between date_trunc(''day'', @fromDate::timestamp ) and date_trunc(''day'', @toDate::timestamp) + ''1 days - 1 milliseconds''
	AND
		mainte_class = ''2''
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
-- 予定
, mainte_tbl as (
	select
		mt.machine_no,
		mt.machine_type,
		mt.machine_serial,
		mt.machine_name,
		mt.com_format_cd,
		mt.bed_name,
		
		mw.mainte_no,
		
		mw.mainte_layout_group_cd,
		mw.mainte_layout_group_edition,
		mlgt.group_name,
		
		mw.mainte_layout_cd,
		mw.mainte_layout_edition,
		mlt.layout_name,

		mw.rec_no,
		mw.mainte_date,
		mw.checker_id_1,
		mw.checker_id_2,
		mw.mainte_ans_1,
		mw.mainte_comment_1 AS header_mainte_comment_1,
		
		mw.tabIndex,
		
		mw.mainte_category_cd,
		mw.mainte_category_edition,
		mct.category_name,
		
		mw.mainte_detail_cd,
		mw.mainte_detail_edition,
		mdt.mainte_content_1 as ment_content_1,
		mdt.mainte_content_2,
		mdt.mainte_content_3,
		
		null as judge,
		mw.comment,
		mw.user_id,
		mw.date,
		mw.up_date
	from
		machine_tbl as mt
		LEFT JOIN mainte_work as mw ON mt.machine_no = mw.machine_no
		LEFT JOIN mst_mainte_layout_group as mlgt ON mw.mainte_layout_group_cd = mlgt.mainte_layout_group_cd AND mw.mainte_layout_group_edition = mlgt.edition_no
		LEFT JOIN mst_mainte_layout as mlt ON mw.mainte_layout_cd = mlt.mainte_layout_cd AND mw.mainte_layout_edition = mlt.edition_no 
		LEFT JOIN mst_mainte_category as mct ON mw.mainte_category_cd = mct.mainte_category_cd AND mw.mainte_category_edition = mct.edition_no 
		LEFT JOIN mst_mainte_detail as mdt ON mw.mainte_detail_cd = mdt.mainte_detail_cd AND mw.mainte_detail_edition = mdt.edition_no 
)
-- 実績
, mainte_hst as (
	SELECT
		mt.machine_no,
		mt.machine_type,
		mt.machine_serial,
		mt.machine_name,
		mt.com_format_cd,
		mt.bed_name,
		
		mhw.mainte_no,
		
		mhw.mainte_layout_group_cd,
		mhw.mainte_layout_group_edition,
		mlgh.group_name,
		
		mhw.mainte_layout_cd,
		mhw.mainte_layout_edition,
		mlh.layout_name,
		
		mhw.rec_no,
		mhw.mainte_date,
		mhw.checker_id_1,
		mhw.checker_id_2,
		mhw.mainte_ans_1,
		mhw.mainte_comment_1 AS header_mainte_comment_1,
		
		mhw.tabIndex,

		mhw.mainte_category_cd,
		mhw.mainte_category_edition,
		mch.category_name,

		mhw.mainte_detail_cd,
		mhw.mainte_detail_edition,
		mdh.mainte_content_1 as ment_content_1,
		mdh.mainte_content_2,
		mdh.mainte_content_3,
		CASE 
			WHEN LENGTH(mhw.judge) <> 0 AND LENGTH(mhw.tabIndex) <> 0 THEN concat(mhw.tabIndex , '','' ,mhw.judge) 
			WHEN LENGTH(mhw.tabIndex) <> 0 THEN concat(mhw.tabIndex , '','')
			ELSE NULL
		END as judge,
		mhw.comment,
		mhw.user_id,
		mhw.date,
		mhw.up_date
	from
		machine_tbl as mt
	LEFT JOIN mainte_work as mhw ON mt.machine_no = mhw.machine_no
	LEFT JOIN mst_mainte_layout_group_hst as mlgh ON mhw.mainte_layout_group_cd = mlgh.mainte_layout_group_cd AND mhw.mainte_layout_group_edition = mlgh.edition_no
	LEFT JOIN mst_mainte_layout_hst as mlh ON mhw.mainte_layout_cd = mlh.mainte_layout_cd AND mhw.mainte_layout_edition = mlh.edition_no 
	LEFT JOIN mst_mainte_category_hst as mch ON mhw.mainte_category_cd = mch.mainte_category_cd AND mhw.mainte_category_edition = mch.edition_no 
	LEFT JOIN mst_mainte_detail_hst as mdh ON mhw.mainte_detail_cd = mdh.mainte_detail_cd AND mhw.mainte_detail_edition = mdh.edition_no	
)

SELECT * FROM(
	SELECT
		*
	FROM
		mainte_hst
	UNION ALL
	SELECT
		*
	FROM
		mainte_tbl
	WHERE
		mainte_layout_cd || '','' || mainte_date not in (select mainte_layout_cd || '','' || mainte_date from mainte_hst)
) a
ORDER BY ARRAY_POSITION(ARRAY[@machineNos], a.machine_no), a.mainte_date, a.layout_name, a.tabindex
', 2, '[{"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_serial", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "com_format_cd", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "bed_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_type", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_no", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "machine_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "group_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "点検レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_layout_cd", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "layout_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "定期点検詳細記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "作業中", "item": "作業中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "定期点検（詳細含む）", "field_name": "mainte_ans_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "checker_id_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_2", "data_name": "確認者", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "checker_id_2", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期検査記録コメント：問題なしです。", "can_calc": "0", "data_code": "header_mainte_comment_1", "data_name": "定期検査記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "header_mainte_comment_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期交換部品記録コメント：問題なしです。", "can_calc": "0", "data_code": "", "data_name": "定期交換部品記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未", "can_calc": "0", "data_code": "judge", "data_name": "確認", "data_type": "string", "conv_table": [{"code": "1,", "disp": "", "item": ""}, {"code": "1,1", "disp": "レ", "item": "レ"}, {"code": "1,2", "disp": "〇", "item": "〇"}, {"code": "1,3", "disp": "✖", "item": "✖"}, {"code": "1,4", "disp": "A", "item": "A"}, {"code": "1,5", "disp": "T", "item": "T"}, {"code": "1,6", "disp": "C", "item": "C"}, {"code": "2,", "disp": "", "item": ""}, {"code": "2,1", "disp": "交換済み", "item": "交換済み"}], "data_class": "定期点検（詳細含む）", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "category_cd", "data_name": "点検カテゴリコード", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "category_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検見出し", "can_calc": "0", "data_code": "category_name", "data_name": "点検見出し", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検対象", "can_calc": "0", "data_code": "ment_content_1", "data_name": "点検対象", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "ment_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検基準/交換部品", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "点検基準/交換部品", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1500", "can_calc": "0", "data_code": "mainte_content_3", "data_name": "交換推奨時間", "data_type": "string", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "mainte_content_3", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検（詳細含む）", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置保守：定期点検詳細 @machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
