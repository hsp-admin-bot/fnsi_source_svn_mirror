DELETE FROM "ntss"."sys_data_set" where sql_cd in (108, 109);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (108, 'with
machine_tbl as (
	SELECT unnest(ARRAY[@machineNos]) AS machine_no
)
, layout_order AS (
  SELECT
    one_json ->> ''code'' as layout_cd
    , json_idx as layout_order 
	FROM
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	WHERE
    facility_cd = @facilityCd
  AND
		master_physical_name = ''mst_mainte_layout''
)
, mainte_layout_tbl as (
  SELECT
    inf.layout_order AS mainte_layout_index,
		mml.mainte_layout_cd,
		mml.edition_no,
		mml.layout_name,
		mml.layout_header
  FROM
    mst_mainte_layout as mml
	left join layout_order as inf
		on (inf.layout_cd ::text = mml.mainte_layout_cd::text)
  WHERE
    facility_cd = @facilityCd
  AND
    layout_class = ''1''
  AND
    is_disp = ''1''
  AND
    is_del = ''0''
	ORDER BY inf.layout_order ASC
)
, mainte_work as (
  SELECT
		ROW_NUMBER() OVER (PARTITION BY machine_no, mainte_date, mw.mainte_layout_cd ORDER BY mw.up_date DESC) AS rn,
    machine_no,
		mainte_date,
		mainte_no,
		rec_no,
		
		mw.mainte_layout_cd,
		mw.mainte_layout_edition,
		mmh.layout_name,
		mmh.layout_header,
		
		checker_id_1,
		checker_id_2,
		mainte_ans_1,
		mw.up_date
  FROM
    mnt_mainte_main as mw
	LEFT JOIN mst_mainte_layout_hst as mmh
		on mw.mainte_layout_cd = mmh.mainte_layout_cd
		and mw.mainte_layout_edition = mmh.edition_no
		and mw.facility_cd = mmh.facility_cd
  WHERE
		machine_no in (@machineNos)
	AND
    mw.facility_cd = @facilityCd
	AND
    mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  AND
    mainte_class = ''1''
  AND
    mw.is_disp = ''1''
  AND
    mw.is_del = ''0''
	ORDER BY machine_no, mainte_date
)
, mainte_tbl as (
	select
		CASE 
			WHEN mw.machine_no IS NOT NULL THEN mw.machine_no
			ELSE -1
		END AS mainte_machine_no,
		mw.mainte_date,
		mw.mainte_no,
		mw.rec_no,
		
		mt.mainte_layout_index,
		mt.mainte_layout_cd,
		CASE
			WHEN mw.mainte_layout_edition IS NOT NULL THEN mw.mainte_layout_edition
			ELSE mt.edition_no
		END AS mainte_layout_edition,
		CASE
			WHEN mw.layout_name IS NOT NULL THEN mw.layout_name
			ELSE mt.layout_name
		END AS layout_name,
		CASE
			WHEN mw.layout_header IS NOT NULL THEN mw.layout_header
			ELSE mt.layout_header
		END AS layout_header,
		
		mw.checker_id_1,
		mw.checker_id_2,
		mw.mainte_ans_1,
		mw.up_date
	from
		mainte_layout_tbl as mt
	left join mainte_work mw
		on mw.mainte_layout_cd = mt.mainte_layout_cd
		and	mw.rn = 1
)
SELECT
	mt.machine_no,
	a.*
FROM
	machine_tbl AS mt
LEFT JOIN (
	select * from mainte_tbl where mainte_machine_no in (@machineNos)
) a ON mt.machine_no = a.mainte_machine_no
ORDER BY ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), a.mainte_layout_index, a.mainte_date DESC
', 2, '[{"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検(基本情報)", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検(基本情報)", "field_name": "mainte_layout_cd", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検(基本情報)", "field_name": "layout_name", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトヘッダー", "can_calc": "0", "data_code": "layout_header", "data_name": "レイアウトヘッダー", "data_type": "string", "conv_table": [], "data_class": "日常点検(基本情報)", "field_name": "layout_header", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合合否", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検(基本情報)", "field_name": "mainte_ans_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "点検者", "data_type": "string", "conv_table": [], "data_class": "日常点検(基本情報)", "field_name": "checker_id_1", "disp_format": "", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2026/03/10 10：21", "can_calc": "0", "data_code": "up_date", "data_name": "最終更新日時", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検(基本情報)", "field_name": "up_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "InspectNull", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '機器保守：日常点検(基本情報) @machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (109, 'with
machine_tbl as (
	SELECT unnest(ARRAY[@machineNos]) AS machine_no
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
, detail_order AS (
  select
    one_json ->> ''code'' as detail_cd
    , json_idx as detail_order 
	from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
	where
    facility_cd = @facilityCd
    and master_physical_name = ''mst_mainte_detail''
)
, mainte_main_tbl as (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY machine_no, mainte_date, mainte_layout_cd ORDER BY up_date DESC) AS rn,
		*
	FROM
		mnt_mainte_main
	WHERE
		machine_no in ( @machineNos )
	AND
		facility_cd = @facilityCd
	AND
		mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
	AND
    mainte_class = ''1''
  AND
    is_disp = ''1''
  AND
    is_del = ''0''
	ORDER BY machine_no, mainte_date	
)
, mainte_work as (
	SELECT
		machine_no,
		mainte_date,
		mainte_no,
		mainte_layout_cd,
		mainte_layout_edition,
    CAST(detail_info ->> ''cate_cd'' AS INTEGER) AS mainte_category_cd,
		CAST(detail_info ->> ''cate_edi'' AS INTEGER) AS mainte_category_edition,
    CAST(detail_info ->> ''detail_cd'' AS INTEGER) AS mainte_detail_cd,
		CAST(detail_info ->> ''detail_edi'' AS INTEGER) AS mainte_detail_edition,
		detail_info ->> ''judge'' as judge,
		detail_info ->> ''comment'' as comment,
		detail_info ->> ''user_id'' as user_id,
		detail_info ->> ''date'' as date
	FROM
		mainte_main_tbl
	CROSS JOIN LATERAL jsonb_array_elements(detail) detail_info
	WHERE
		rn = 1
)
, mainte_layout_tbl as (
  SELECT
    mlo.layout_order,
    mainte_layout_cd,
		edition_no,
		layout_name,
		layout_header
  FROM
    mst_mainte_layout as la
	LEFT JOIN layout_order AS mlo ON (mlo.layout_cd::text = la.mainte_layout_cd::text)
  WHERE
    facility_cd = @facilityCd
  AND
    layout_class = ''1''
  AND
    is_disp = ''1''
  AND
    is_del = ''0''
)
, mainte_hst as (
	SELECT
		mhw.machine_no AS mainte_machine_no,
		mhw.mainte_date,
		mhw.mainte_no,
		
		mhw.mainte_layout_cd,
		mhw.mainte_layout_edition,
		mlh.layout_name,
		mlh.layout_header,
		
		mco.category_order as mainte_category_idx,
		mhw.mainte_category_cd,
		mhw.mainte_category_edition,
		mch.category_name,

		mdo.detail_order as mainte_detail_idx,
		mhw.mainte_detail_cd,
		mhw.mainte_detail_edition,
		mdh.mainte_content_1,
		mdh.mainte_content_2,
		mdh.mainte_content_3,
		
		mhw.judge,
		mhw.comment,
		mhw.user_id,
		mhw.date
	from
		 mainte_work mhw
	LEFT JOIN mst_mainte_layout_hst as mlh ON mhw.mainte_layout_cd = mlh.mainte_layout_cd AND mhw.mainte_layout_edition = mlh.edition_no 
	LEFT JOIN mst_mainte_category_hst as mch ON mhw.mainte_category_cd = mch.mainte_category_cd AND mhw.mainte_category_edition = mch.edition_no 
	LEFT JOIN mst_mainte_detail_hst as mdh ON mhw.mainte_detail_cd = mdh.mainte_detail_cd AND mhw.mainte_detail_edition = mdh.edition_no
	LEFT JOIN category_order as mco ON (mco.category_cd::text = mhw.mainte_category_cd::text)
	LEFT JOIN detail_order as mdo ON (mdo.detail_cd::text = mhw.mainte_detail_cd::text)
)
, result_tbl as (
	SELECT
		CASE WHEN a.mainte_layout_cd IS NULL THEN -1
			ELSE a.mainte_machine_no END AS mainte_machine_no,
		a.mainte_date,
		a.mainte_no,
		
		la.layout_order as mainte_layout_index,
		la.mainte_layout_cd,
		CASE WHEN a.mainte_layout_edition IS NULL THEN la.edition_no
			ELSE a.mainte_layout_edition END AS mainte_layout_edition,
		CASE WHEN a.layout_name IS NULL THEN la.layout_name
			ELSE a.layout_name END AS layout_name,
		CASE WHEN a.layout_header IS NULL THEN la.layout_header
			ELSE a.layout_header END AS layout_header,	
		
		a.mainte_category_idx,
		a.mainte_category_cd,
		a.mainte_category_edition,
		a.category_name,

		a.mainte_detail_idx,
		a.mainte_detail_cd,
		a.mainte_detail_edition,
		a.mainte_content_1,
		a.mainte_content_2,
		a.mainte_content_3,
		
		a.judge,
		a.comment,
		a.user_id,
		a.date
	FROM
		mainte_layout_tbl as la
	LEFT JOIN mainte_hst AS a ON la.mainte_layout_cd = a.mainte_layout_cd
	ORDER BY la.layout_order
)

SELECT
	mt.machine_no,
	a.*
FROM
	machine_tbl AS mt
LEFT JOIN result_tbl as a ON mt.machine_no = a.mainte_machine_no
ORDER BY ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), a.mainte_layout_index, a.mainte_date DESC, a.mainte_category_idx, a.mainte_detail_idx
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "mainte_layout_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "layout_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトヘッダー", "can_calc": "0", "data_code": "layout_header", "data_name": "レイアウトヘッダー", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "layout_header", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_category_cd", "data_name": "グループコード", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "mainte_category_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "グループ名", "can_calc": "0", "data_code": "category_name", "data_name": "グループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内容1", "can_calc": "0", "data_code": "mainte_content_1", "data_name": "内容1", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "mainte_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内容2", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "内容2", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "judge", "data_name": "結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検(記録簿)", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "comment", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "user_id", "data_name": "個別点検者", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "user_id", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2026/03/10 10:35", "can_calc": "0", "data_code": "date", "data_name": "実施日時", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '機器保守：日常点検(記録簿) @machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);