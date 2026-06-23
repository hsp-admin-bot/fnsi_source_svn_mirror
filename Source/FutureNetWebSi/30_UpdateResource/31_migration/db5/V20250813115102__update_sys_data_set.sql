DELETE FROM "ntss"."sys_data_set" where sql_cd in (108, 109, 127, 149, 152, 153);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (108, 'with
bed_tbl AS (
	SELECT
		bed_cd
		, bed_name
		, machine_no
	FROM
		mst_bed
	WHERE
		facility_cd = @facilityCd
	AND
    is_disp = ''1''
  AND
    is_del = ''0''
)
, machine_tbl as (
  select
    mm.*,
    mmt.machine_type,
		bed.bed_name
  from
    mst_machine as mm
	left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
	left join bed_tbl as bed on mm.machine_no = bed.machine_no
  where
    mm.machine_no in (@machineNos)
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
-- 予定
, mainte_layout_tbl as (
  select
    inf.layout_order AS mainte_layout_index,
    *
  from
    mst_mainte_layout as mml
	left join layout_order as inf
		on (inf.layout_cd ::text = mml.mainte_layout_cd::text)
  where
    facility_cd = @facilityCd
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY inf.layout_order ASC
)
-- 実績
, mainte_layout_hst as (
  select
    *
  from
    mst_mainte_layout_hst as mmlh
	left join layout_order as inf
		on (inf.layout_cd ::text = mmlh.mainte_layout_cd::text)
  where
    facility_cd = @facilityCd
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY inf.layout_order ASC
)
, mainte_work as (
  select
    *
  from
    mnt_mainte_main
  where
    mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  and
    mainte_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''
	ORDER BY mainte_date
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
		mt.edition_no AS mainte_layout_edition,
		mt.layout_name,
		
    mw.mainte_no,
    mw.mainte_class,
    mw.rec_no,
    mw.mainte_date,
    mg.group_name,
    
    mw.checker_id_1,
    mw.checker_id_2,
    mw.mainte_ans_1,
    to_char(mw.up_date, ''YYYY/MM/DD'') as up_date
  from
    machine_mainte_layout_all as mt
    left join mainte_work mw
		on mw.machine_no = mt.machine_no
		and mw.mainte_layout_cd = mt.mainte_layout_cd
    left join mst_mainte_layout_group as mg 
		on mg.mainte_layout_group_cd = mw.mainte_layout_group_cd
		and mg.facility_cd = mw.facility_cd
    ORDER BY ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), mt.mainte_layout_index	  
)
select * from mainte_hst
', 2, '[{"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "com_format_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "bed_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細無し）", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "点検レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "mainte_layout_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細無し）", "field_name": "up_date", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置保守：日常点検　@machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (109, 'with
bed_tbl AS (
	SELECT
		bed_cd
		, bed_name
		, machine_no
	FROM
		mst_bed
	WHERE
		facility_cd = @facilityCd
	AND
    is_disp = ''1''
  AND
    is_del = ''0''
)
, machine_tbl as (
  select
    mm.*,
    mmt.machine_type,
    bed.bed_name
  from
    mst_machine as mm
	left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
	left join bed_tbl as bed on mm.machine_no = bed.machine_no
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
	ORDER BY la.layout_cd_order ASC	
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
	ORDER BY la.layout_cd_order ASC
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
', 2, '[{"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "P", "can_calc": "0", "data_code": "com_format_cd", "data_name": "通信フォーマット", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "com_format_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "bed_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-100NX_113", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "machine_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細含む）", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "点検レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_layout_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "judge", "data_name": "合否", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検（詳細含む）", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "comment", "data_name": "点検コメント", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "category_cd", "data_name": "点検カテゴリコード", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "category_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検見出し", "can_calc": "0", "data_code": "category_name", "data_name": "点検見出し", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検対象", "can_calc": "0", "data_code": "mainte_content_1", "data_name": "点検対象", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検基準", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "点検基準", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検者", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "user_id", "data_name": "点検者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "user_id", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/17", "can_calc": "0", "data_code": "date", "data_name": "個別点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "string", "conv_table": [], "data_class": "日常点検（詳細含む）", "field_name": "up_date", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置保守：日常点検詳細　@machineNos @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (127, 'with machine_tbl as (
  select
    *
  from
    mst_machine
  where
    facility_cd = @facilityCd
  and
    is_disp = ''1''
  and
    is_del = ''0''
  and
		machine_no in (@machineNos)
)
, water_survey_type_tbl as (
  select
    survey_type_cd,
    survey_type_name,
    integer_digits,
    decimal_digits,
    initial_string
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
    mwsp.survey_point_cd,
    mwsp.point_name,
    case when mwsp.machine_no is not null then mwsp.machine_no
		else -1 end as machine_no,
    mt.machine_name,
    mwsp.survey_type_cd,
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
    machine_no,
    machine_name,
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
				|| (case when (wst.text is not null and wst.text <> ''0'' and wst.text <> '''') then (select jsonb_array_elements(wstt.initial_string::JSONB)->>''text'' LIMIT 1 OFFSET CAST(wst.text AS INTEGER) - 1)
				else '''' end)
      when (wst.memo <> '''' or wst.time <> '''' or CAST(wst.picker AS INTEGER) != 0 or CAST(wst.inspector AS INTEGER) != 0) then ''検査中''
      when (wst.text is not null and wst.text <> ''0'' and wst.text <> '''') then (select jsonb_array_elements(wstt.initial_string::JSONB)->>''text'' LIMIT 1 OFFSET CAST(wst.text AS INTEGER) - 1)
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
		lpad(disp_order::text, 19, ''0'') as point_disp_order
		,cells.index
		,cells.machine_no
		,cells.machine_name
		,cells.survey_type_cd
		,case
			when (cells.survey_type_cd is not null) then water_survey_type_tbl.survey_type_name
			else null
		end as survey_type_name
		,cells.survey_point_cd
		,cells.point_name
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
', 2, '[{"preview": "0000000000000000010", "can_calc": "0", "data_code": "point_disp_order", "data_name": "調査箇所表示順", "data_type": "string", "conv_table": [], "data_class": "水質管理", "field_name": "point_disp_order", "disp_format": "", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "水質管理", "field_name": "machine_no", "disp_format": "", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DAB", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "水質管理", "field_name": "machine_name", "disp_format": "", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "survey_type_cd", "data_name": "水質検査種別コード", "data_type": "string", "conv_table": [], "data_class": "水質管理", "field_name": "survey_type_cd", "disp_format": "", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ET", "can_calc": "0", "data_code": "survey_type_name", "data_name": "水質検査種別", "data_type": "string", "conv_table": [], "data_class": "水質管理", "field_name": "survey_type_name", "disp_format": "", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "survey_point_cd", "data_name": "水質検査箇所コード", "data_type": "string", "conv_table": [], "data_class": "水質管理", "field_name": "survey_point_cd", "disp_format": "", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "B原液タンク(ET)", "can_calc": "0", "data_code": "point_name", "data_name": "調査箇所名", "data_type": "string", "conv_table": [], "data_class": "水質管理", "field_name": "point_name", "disp_format": "", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/01/24", "can_calc": "0", "data_code": "inspection_date_str", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "水質管理", "field_name": "inspection_date_str", "disp_format": "yyyy/mm/dd", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200EU/mL未満", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "水質管理", "field_name": "result", "disp_format": "", "data_category": "水質管理", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '水質調査 @machineNos @facilityCd @fromDate @toDateを使用', '2020-04-02 00:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (149, 'WITH mst_equi AS (
	SELECT
		equipment_cd,
		equipment_name
	FROM
		mst_equipment
	WHERE
		facility_cd = @facilityCd
),
mst_equic AS (
	SELECT
		class_cd,
		class_name
	FROM
		mst_equipment_class
	WHERE
		facility_cd = @facilityCd
),
mst_medi AS (
	SELECT
		medicine_cd,
		medicine_name
	FROM
		mst_medicine
	WHERE
		facility_cd = @facilityCd
),
mst_medic AS (
	SELECT
		class_cd,
		class_name
	FROM
		mst_medicine_class
	WHERE
		facility_cd = @facilityCd
),
mst_medim AS (
	SELECT
		medicine_mix_cd,
		medicine_mix_name
	FROM
		mst_medicine_mix
	WHERE
		facility_cd = @facilityCd
),
mst_dial AS (
	SELECT
		dialyzer_cd,
		model_number
	FROM
		mst_dialyzer
	WHERE
		facility_cd = @facilityCd
)

SELECT
	supplies_cd,
	CASE
		WHEN medicine_no::TEXT IS NOT NULL THEN medicine_no ->>''no''::TEXT
		ELSE medicine_no::TEXT
	END AS medi_info_no,
	supplies_source_class,
	supplies_class,
	CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN supplies_cd
	END AS equipment_cd,
	CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'',''01'') THEN supplies_cd
	END AS medicine_cd,
	CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN equipment_name
		   WHEN supplies_class IN (''08'',''09'',''10'',''12'') THEN medicine_name
		   WHEN supplies_class IN (''13'',''17'') THEN medicine_mix_name
		   WHEN supplies_class IN (''01'') THEN model_number
	END AS supplies_name,
	CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd
		   ELSE ''-1''
	END AS class_cd,
	CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN mec.class_name
	     WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN mmc.class_name
	     WHEN supplies_class IN (''01'') THEN ''ダイアライザ''
			 END AS class_name,
	supplies_base_date,
-- 	ind_rst_value
	CASE WHEN supplies_class IN (''13'',''17'')  THEN ''1''
		ELSE COALESCE(NULLIF(receipt_value, ''''), ''0'')
	END AS ind_rst_value
FROM
	ord_material_save oms
LEFT JOIN mst_equi me ON oms.supplies_cd::INTEGER = me.equipment_cd
LEFT JOIN mst_equic mec ON oms.class_cd::INTEGER = mec.class_cd
LEFT JOIN mst_medi mm ON oms.supplies_cd::INTEGER = mm.medicine_cd
LEFT JOIN mst_medic mmc ON oms.class_cd::INTEGER = mmc.class_cd
LEFT JOIN mst_medim mmm ON oms.supplies_cd::INTEGER = mmm.medicine_mix_cd
LEFT JOIN mst_dialyzer md ON oms.supplies_cd::INTEGER = md.dialyzer_cd
WHERE
	pat_id in (@patIds)
AND oms.facility_cd = @facilityCd
AND supplies_base_no in (@ordNos)
AND supplies_base_date::TIMESTAMP BETWEEN date_trunc(''day'', @fromDate ::timestamp) AND date_trunc(''day'', @toDate ::timestamp)
AND	ind_rst_class = ''1''
AND supplies_class <> ''16''
AND supplies_class <> ''23''
AND supplies_class <> ''24''
AND CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN
					 CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd::INTEGER IN (@eqIds)
					 ELSE -1 IN (@eqIds)
					 END
		     WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN
					 CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd::INTEGER IN (@medIds)
					 ELSE -1 IN (@medIds)
					 END
		     WHEN supplies_class IN (''01'') THEN supplies_cd::INTEGER IN (@diaIds)
	  END
ORDER BY
	CASE supplies_class
		WHEN ''01'' THEN 1  
		WHEN ''00'' THEN 2  
		WHEN ''02'' THEN 2  
		WHEN ''03'' THEN 2  
		WHEN ''04'' THEN 2  
		WHEN ''05'' THEN 2  
		WHEN ''06'' THEN 2  
		WHEN ''07'' THEN 2  
		WHEN ''11'' THEN 2  
		WHEN ''13'' THEN 3  
		WHEN ''17'' THEN 3  
		WHEN ''08'' THEN 4  
		WHEN ''09'' THEN 4  
		WHEN ''10'' THEN 4  
		WHEN ''12'' THEN 4  
		ELSE 5
		END,
	class_name NULLS LAST,
	supplies_name NULLS LAST
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "supplies_cd", "data_name": "物品コード", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_cd", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "medi_info_no", "data_name": "薬剤識別番号", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "medi_info_no", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "supplies_source_class", "data_name": "データ発生元区分", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_source_class", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00", "can_calc": "0", "data_code": "supplies_class", "data_name": "物品区分", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_class", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "supplies_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_name", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "supplies_base_date", "data_name": "データ基準日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "supplies_base_date", "disp_format": "yyyy/mm/dd", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ind_rst_value", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "ind_rst_value", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [10, 11]}', '薬剤週間薬剤集計表 @patId @facilityCd  @fromdate  @todate', '2021-04-25 16:40:02', CURRENT_TIMESTAMP, '[]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (152, 'with mb as (
		select * from mst_bed where facility_cd = @facilityCd and is_disp = ''1'' and is_del = ''0'' and machine_no is not null
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
		pat_main.is_same as first_name_is_same,
		pat_main.is_same as pat_name_is_same
		from
    ord_main
		left join pat_main
    on pat_main.pat_id = ord_main.pat_id
		where
    ord_main.facility_cd = @facilityCd
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
    facility_cd = @facilityCd and master_physical_name = ''mst_bed''
		)
		, kur_disp_order_tbl as (
		select
		one_json->>''code'' as kur_cd
		,json_idx as kur_disp_order
		from
		mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(one_json, json_idx)
		where
		facility_cd = @facilityCd and master_physical_name = ''mst_kur''
		)

		select
		om.first_name_is_same
		,om.pat_name_is_same
		,pat_id as pat_last_name_id
		,pat_id as in_out_class
		,pat_id
		,lpad(bed_disp_order::text, 19, ''0'') as bed_disp_order
		,sche_cells.bed_name
		,sche_cells.bed_cd
		,sche_cells.treat_date
		,lpad(kur_disp_order::text, 19, ''0'') as kur_disp_order
		,sche_cells.kur_cd
		,sche_cells.kur_name
		,mb.in_hospital_cd_1
		,mb.in_hospital_cd_2
		from
		sche_cells
		left outer join om
    on sche_cells.treat_date = om.treat_date 
		and sche_cells.bed_cd = om.ind_bed_cd
		and sche_cells.kur_cd = om.ind_kur_cd
		left outer join bed_disp_order_tbl
    on sche_cells.bed_cd::text = bed_disp_order_tbl.bed_cd::text
		left join  mb
		on 	   mb.bed_cd=sche_cells.bed_cd
		left outer join kur_disp_order_tbl
    on sche_cells.kur_cd::text = kur_disp_order_tbl.kur_cd::text
		where om.pat_id in (@patIds)
		and om.facility_cd = @facilityCd
    ORDER BY bed_disp_order, sche_cells.treat_date, kur_disp_order
;', 2, '[{"preview": "テスト患者姓", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_last_name", "target_var": "@patId"}, "data_code": "pat_last_name", "data_name": "患者名（姓のみ）", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "pat_last_name_id", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "なし", "can_calc": "0", "data_code": "first_name_is_same", "data_name": "患者名（姓のみ）+同姓フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "スケジュール表", "field_name": "first_name_is_same", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "pat_id", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "data_code": "pat_name_is_same", "data_name": "患者名+同姓同名フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "なし"}, {"code": "1", "disp": "*", "item": "あり"}], "data_class": "スケジュール表", "field_name": "pat_name_is_same", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "in_out_class", "target_var": "@patId"}, "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}, {"code": "2", "disp": "死亡", "item": "死亡"}, {"code": "3", "disp": "(不在)", "item": "(不在)"}], "data_class": "スケジュール表", "field_name": "in_out_class", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0000000000000000010", "can_calc": "0", "data_code": "bed_disp_order", "data_name": "ベッド表示順", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_disp_order", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "bed_cd", "data_name": "ベッドコード", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_cd", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストベッド０１", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "連携コード1", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "連携コード2", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/04/07", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "スケジュール表", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "kur_cd", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "kur_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '２次元スケジュール表 @facilityCd @fromdate @todate @patIds @kurCds @bedCds', '2021-05-10 16:40:02', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (153, 'with mk as (
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
    mk, treat_date_records
)
, om as (
  select
    *
  from
    ord_main
  where
    facility_cd = @facilityCd
  and
    treat_date between to_char(date_trunc(''day'', ( @fromDate )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
  and
    is_del = ''0''
)
, bed_unreg_count_tbl as (
  select
    treat_date, ind_kur_cd, count(*) as bed_unreg_count
  from
    om
  where
    ind_bed_cd = 0 and ind_kur_cd <> 0
  group by
    treat_date, ind_kur_cd
  order by
    treat_date
)
, count_tbl as (
  select
    treat_date, ind_kur_cd, count(*) as count
  from
    om
  inner join
    mst_bed bed
  on
    bed.facility_cd = @facilityCd and bed.bed_cd = ind_bed_cd
  where
    ind_bed_cd <> 0  and ind_kur_cd <> 0 and bed.is_disp <> ''0'' and bed.is_del <> ''1'' and bed.machine_no is not NULL
  group by
    treat_date, ind_kur_cd
  order by
    treat_date
)

select
  sche_cells.treat_date
	,sche_cells.kur_cd
  ,sche_cells.kur_name
  ,case when bed_unreg_count is not null then bed_unreg_count else 0 end as bed_unreg_count
  ,case when count is not null then count else 0 end as count
  ,''dummy_bed_name'' as dummy_bed_name
from
  sche_cells
  left outer join bed_unreg_count_tbl
    on sche_cells.treat_date = bed_unreg_count_tbl.treat_date and sche_cells.kur_cd = bed_unreg_count_tbl.ind_kur_cd
  left outer join count_tbl
    on sche_cells.treat_date = count_tbl.treat_date and sche_cells.kur_cd = count_tbl.ind_kur_cd
order by
  sche_cells.treat_date, kur_start_time
;', 2, '[{"preview": "5", "can_calc": "0", "data_code": "bed_unreg_count", "data_name": "ベッド未登録数", "data_type": "decimal", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "bed_unreg_count", "disp_format": "0", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "23", "can_calc": "0", "data_code": "count", "data_name": "予約数", "data_type": "decimal", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "count", "disp_format": "0", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200407", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "kur_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', 'スゲ0ージュル表 @facilityCd @fromdate @todate @kurCds', '2021-05-10 16:40:02', CURRENT_TIMESTAMP, '[]');
