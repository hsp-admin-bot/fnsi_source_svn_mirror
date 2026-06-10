DELETE FROM "ntss"."sys_data_set" where sql_cd in (108, 109, 110, 111, 264);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (108, 'with
machine_tbl as (
	SELECT unnest(ARRAY[@machineNos]) AS machine_no
)
-- 予定
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
    *
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
		ROW_NUMBER() OVER (PARTITION BY machine_no, mainte_date, mainte_layout_cd ORDER BY up_date DESC) AS rn,
    *
  FROM
    mnt_mainte_main
  WHERE
		machine_no in (@machineNos)
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
		mt.edition_no AS mainte_layout_edition,
		mt.layout_name,
		mt.layout_header,
		
		mw.checker_id_1,
		mw.checker_id_2,
		mw.mainte_ans_1,
		mw.up_date
	from
		mainte_layout_tbl as mt
	left join mainte_work mw
		on mw.mainte_layout_cd = mt.mainte_layout_cd
		and mt.facility_cd = mw.facility_cd
	WHERE
		mw.rn = 1
)
SELECT
	mt.machine_no,
	a.*
FROM
	machine_tbl AS mt
LEFT JOIN (
	select * from mainte_tbl where mainte_machine_no in (@machineNos)
) a ON mt.machine_no = a.mainte_machine_no
ORDER BY a.mainte_layout_index, a.mainte_date DESC, ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no)	
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
-- 予定
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
, mainte_tbl as (
		SELECT
		mw.machine_no AS mainte_machine_no,
		mw.mainte_date,
		mw.mainte_no,
		
		mw.mainte_layout_cd,
		mw.mainte_layout_edition,
		mt.layout_name,
		mt.layout_header,
		
		mco.category_order as mainte_category_idx,
		mw.mainte_category_cd,
		mw.mainte_category_edition,
		mct.category_name,

		mdo.detail_order as mainte_detail_idx,
		mw.mainte_detail_cd,
		mw.mainte_detail_edition,
		mdt.mainte_content_1,
		mdt.mainte_content_2,
		mdt.mainte_content_3,
		
		mw.judge,
		mw.comment,
		mw.user_id,
		mw.date
	FROM
		mainte_work mw
	LEFT JOIN mainte_layout_tbl as mt ON mw.mainte_layout_cd = mt.mainte_layout_cd AND mw.mainte_layout_edition = mt.edition_no 
	LEFT JOIN mst_mainte_category as mct ON mw.mainte_category_cd = mct.mainte_category_cd AND mw.mainte_category_edition = mct.edition_no 
	LEFT JOIN mst_mainte_detail as mdt ON mw.mainte_detail_cd = mdt.mainte_detail_cd AND mw.mainte_detail_edition = mdt.edition_no
	LEFT JOIN category_order as mco ON (mco.category_cd::text = mw.mainte_category_cd::text)
	LEFT JOIN detail_order as mdo ON (mdo.detail_cd::text = mw.mainte_detail_cd::text)
	WHERE
		mt.layout_name IS NOT NULL
)
-- 実績
, mainte_layout_hst as (
  SELECT
    *
  FROM
    mst_mainte_layout_hst
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
	LEFT JOIN mainte_layout_hst as mlh ON mhw.mainte_layout_cd = mlh.mainte_layout_cd AND mhw.mainte_layout_edition = mlh.edition_no 
	LEFT JOIN mst_mainte_category_hst as mch ON mhw.mainte_category_cd = mch.mainte_category_cd AND mhw.mainte_category_edition = mch.edition_no 
	LEFT JOIN mst_mainte_detail_hst as mdh ON mhw.mainte_detail_cd = mdh.mainte_detail_cd AND mhw.mainte_detail_edition = mdh.edition_no
	LEFT JOIN category_order as mco ON (mco.category_cd::text = mhw.mainte_category_cd::text)
	LEFT JOIN detail_order as mdo ON (mdo.detail_cd::text = mhw.mainte_detail_cd::text)
	WHERE
		mlh.layout_name IS NOT NULL
)
, result_tbl as (
	SELECT
		CASE WHEN a.mainte_layout_cd IS NULL THEN -1
			ELSE a.mainte_machine_no END AS mainte_machine_no,
		a.mainte_date,
		a.mainte_no,
		
		la.layout_order as mainte_layout_index,
		CASE WHEN a.mainte_layout_cd IS NULL THEN la.mainte_layout_cd
			ELSE a.mainte_layout_cd END AS mainte_layout_cd,
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
	LEFT JOIN (
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
	) a ON la.mainte_layout_cd = a.mainte_layout_cd
	ORDER BY la.layout_order
)


SELECT
	mt.machine_no,
	a.*
FROM
	machine_tbl AS mt
LEFT JOIN result_tbl as a ON mt.machine_no = a.mainte_machine_no
ORDER BY a.mainte_layout_index, a.mainte_date DESC, ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), a.mainte_category_idx, a.mainte_detail_idx
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "mainte_layout_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "layout_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトヘッダー", "can_calc": "0", "data_code": "layout_header", "data_name": "レイアウトヘッダー", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "layout_header", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_category_cd", "data_name": "グループコード", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "mainte_category_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "グループ名", "can_calc": "0", "data_code": "category_name", "data_name": "グループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内容1", "can_calc": "0", "data_code": "mainte_content_1", "data_name": "内容1", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "mainte_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内容2", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "内容2", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "judge", "data_name": "結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検(記録簿)", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "comment", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "user_id", "data_name": "個別点検者", "data_type": "string", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "user_id", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2026/03/10 10:35", "can_calc": "0", "data_code": "date", "data_name": "実施日時", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検(記録簿)", "field_name": "date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '機器保守：日常点検(記録簿) @machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (110, 'with
machine_tbl as (
	SELECT
		machine_no,
		machine_type_cd
	FROM
		mst_machine
	WHERE 
		machine_no in (@machineNos)
	AND
		is_disp =''1''
	AND
		is_del = ''0''
)
-- 予定
, mainte_work as (
	SELECT
		*
	FROM
		mnt_mainte_main
	WHERE 
		facility_cd = @facilityCd
	AND
		machine_no in (@machineNos)
	AND
		mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
	AND
		mainte_class = ''2''
	AND
		mainte_ans_1 is null
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
-- 実績
, mainte_hst_work as (
	SELECT
		*
	FROM
		mnt_mainte_main
	WHERE 
		facility_cd = @facilityCd
	AND
		machine_no in (@machineNos)
	AND
		mainte_date between date_trunc(''day'',@fromDate ::timestamp ) and date_trunc(''day'',@toDate ::timestamp) + ''1 days - 1 milliseconds''
	AND
		mainte_class = ''2''
	AND
		mainte_ans_1 is not null
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
, mainte_tbl as (
	SELECT
		mw.machine_no AS mainte_machine_no,
		mw.mainte_date,
		mw.mainte_no,
		mw.rec_no,
		
		mw.mainte_layout_group_cd,
		mw.mainte_layout_group_edition,
		mlgt.group_name as layout_group_name,
		
		mlt.mainte_layout_cd,
		mw.mainte_layout_edition,
		mlt.layout_name,

		mw.checker_id_1,
		mw.checker_id_2,
		CASE WHEN mw.mainte_ans_1 IS NOT NULL THEN mw.mainte_ans_1 ELSE ''0'' END as mainte_ans_1,
		(CASE WHEN mw.mainte_ans_1 IS NOT NULL THEN mw.mainte_ans_1 ELSE ''0'' END) || mlgt.group_name as layout_group_ans,
		mw.mainte_comment_1,
		mw.up_date
	FROM
		mainte_work as mw
	inner join machine_tbl as mt
		on mw.machine_no = mt.machine_no
	left join mst_mainte_layout_group as mlgt
		on mw.mainte_layout_group_cd = mlgt.mainte_layout_group_cd
		and mw.mainte_layout_group_edition = mlgt.edition_no
	left join mst_mainte_layout as mlt
		on (mlt.mainte_layout_cd::text  in (SELECT json_array_elements_text((SELECT to_json(mlgt.layout_list)))::text))
		and mt.machine_type_cd::text in (SELECT json_array_elements_text((SELECT to_json(mlt.type_info)))::text)
)
, mainte_hst as (
	SELECT
		mhw.machine_no AS mainte_machine_no,
		mhw.mainte_date,
		mhw.mainte_no,
		mhw.rec_no,
		
		mhw.mainte_layout_group_cd,
		mhw.mainte_layout_group_edition,
		mlgh.group_name as layout_group_name,
		
		mlh.mainte_layout_cd,
		mhw.mainte_layout_edition,
		mlh.layout_name,

		mhw.checker_id_1,
		mhw.checker_id_2,
		CASE WHEN mhw.mainte_ans_1 IS NOT NULL THEN mhw.mainte_ans_1 ELSE ''0'' END as mainte_ans_1,
		(CASE WHEN mhw.mainte_ans_1 IS NOT NULL THEN mhw.mainte_ans_1 ELSE ''0'' END) || mlgh.group_name as layout_group_ans,
		mhw.mainte_comment_1,
		mhw.up_date
	FROM
		mainte_hst_work mhw
	inner join machine_tbl as mt
		on mhw.machine_no = mt.machine_no
	left join mst_mainte_layout_group_hst as mlgh
		on mhw.mainte_layout_group_cd = mlgh.mainte_layout_group_cd and mhw.mainte_layout_group_edition = mlgh.edition_no
	left join mst_mainte_layout_hst as mlh
		on mlh.mainte_layout_cd ::text in
			(SELECT json_array_elements_text((SELECT to_json(mlgh.layout_list)))::text) and mhw.mainte_layout_edition = mlh.edition_no
		and mhw.mainte_layout_cd = mlh.mainte_layout_cd 
)
, result_table as (
	SELECT
		rt.*,
		prev.mainte_date as last_mainte_date,
		nep.mainte_date as next_plan_date
	FROM
		(select * from mainte_tbl union all select * from mainte_hst) rt
	LEFT JOIN LATERAL (
		SELECT
			p1.mainte_date
		FROM mnt_mainte_main p1
		WHERE p1.machine_no = rt.mainte_machine_no
			AND p1.facility_cd = @facilityCd
			AND p1.mainte_class = ''2''
			AND p1.is_del = ''0''
			AND p1.is_disp = ''1''
			AND p1.mainte_date < date_trunc(''day'', rt.mainte_date)
			AND p1.mainte_date >= date_trunc(''day'', rt.mainte_date) - INTERVAL ''1 year''
			AND p1.mainte_ans_1 is not null
		ORDER BY p1.mainte_date DESC
		LIMIT 1
	) prev ON TRUE
	LEFT JOIN LATERAL (
		SELECT
			p2.mainte_date
		FROM mnt_mainte_main p2
		WHERE p2.machine_no = rt.mainte_machine_no
			AND p2.facility_cd = @facilityCd
			AND p2.mainte_class = ''2''
			AND p2.is_del = ''0''
			AND p2.is_disp = ''1''
			AND p2.mainte_date > date_trunc(''day'', rt.mainte_date)
			AND p2.mainte_date <= date_trunc(''day'', rt.mainte_date) + INTERVAL ''1 year''
			AND p2.mainte_ans_1 is null
		ORDER BY p2.mainte_date ASC
		LIMIT 1
	) nep ON TRUE
)

SELECT
	mt.machine_no,
	rt.*
FROM
	machine_tbl AS mt
LEFT JOIN result_table rt ON mt.machine_no = rt.mainte_machine_no
ORDER BY ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), rt.mainte_date, rt.layout_name
', 2, '[{"preview": "I7012104", "can_calc": "0", "data_code": "rec_no", "data_name": "記録番号", "data_type": "string", "conv_table": [], "data_class": "定期点検(基本情報)", "field_name": "rec_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検実施日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検(基本情報)", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_layout_group_cd", "data_name": "機種別レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "定期点検(基本情報)", "field_name": "mainte_layout_group_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "機種別レイアウト名", "can_calc": "0", "data_code": "layout_group_name", "data_name": "機種別レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検(基本情報)", "field_name": "layout_group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "予定あり", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "作業中", "item": "作業中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "定期点検(基本情報)", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇機種別レイアウト名", "can_calc": "0", "data_code": "layout_group_ans", "data_name": "総合判定+点検名", "data_type": "string", "conv_table": [{"code": "0", "disp": "〇", "item": "予定あり"}, {"code": "1", "disp": "●", "item": "合格"}, {"code": "2", "disp": "⦿", "item": "作業中"}, {"code": "3", "disp": "✕", "item": "不合格"}], "data_class": "定期点検(基本情報)", "field_name": "layout_group_ans", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期検査記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "点検者コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検(基本情報)", "field_name": "mainte_comment_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "点検者", "data_type": "string", "conv_table": [], "data_class": "定期点検(基本情報)", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_2", "data_name": "確認者", "data_type": "string", "conv_table": [], "data_class": "定期点検(基本情報)", "field_name": "checker_id_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16 10:50", "can_calc": "0", "data_code": "up_date", "data_name": "最終更新日時", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検(基本情報)", "field_name": "up_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2026/03/10", "can_calc": "0", "data_code": "next_plan_date", "data_name": "次回点検予定日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検(基本情報)", "field_name": "next_plan_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2026/03/10", "can_calc": "0", "data_code": "last_mainte_date", "data_name": "前回点検実施日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検(基本情報)", "field_name": "last_mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '機器保守：定期点検(基本情報) @machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (111, 'with
machine_tbl as (
	SELECT
		machine_no,
		machine_type_cd
	FROM
		mst_machine
	WHERE 
		machine_no in (@machineNos)
	AND
		is_disp =''1''
	AND
		is_del = ''0''
)
, mainte_work as (
	SELECT
		machine_no,
		mainte_date,
		mainte_no,
		
		mainte_layout_cd,
		mainte_layout_edition,
		
		detail_info ->> ''tableIndex'' AS tabIndex,
		
    CAST(detail_info ->> ''cate_cd'' AS INTEGER) AS mainte_category_cd,
		CAST(detail_info ->> ''cate_edi'' AS INTEGER) AS mainte_category_edition,
    CAST(detail_info ->> ''detail_cd'' AS INTEGER) AS mainte_detail_cd,
		CAST(detail_info ->> ''edition'' AS INTEGER) AS mainte_detail_edition,
		detail_info ->> ''judge'' as judge,
		detail_info ->> ''comment'' as mainte_comment,
		detail_info ->> ''user_id'' as user_id,
		detail_info ->> ''date'' as date
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
	AND	
		detail_info ->> ''tableIndex'' = ''1''
)
-- 予定
, mainte_tbl as (
	select
		mw.machine_no AS mainte_machine_no,
		mw.mainte_date,
		mw.mainte_no,
		
		mw.mainte_layout_cd,
		mw.mainte_layout_edition,
		mlt.layout_name,
		mlt.layout_header,

		mw.tabIndex,
		
		mw.mainte_category_cd,
		mw.mainte_category_edition,
		mct.category_name,
		
		mw.mainte_detail_cd,
		mw.mainte_detail_edition,
		mdt.mainte_content_1,
		mdt.mainte_content_2,
		mdt.mainte_content_3,
		
		null as judge,
		mw.mainte_comment,
		mw.user_id,
		mw.date
	from
		mainte_work as mw
		LEFT JOIN mst_mainte_layout as mlt ON mw.mainte_layout_cd = mlt.mainte_layout_cd AND mw.mainte_layout_edition = mlt.edition_no 
		LEFT JOIN mst_mainte_category as mct ON mw.mainte_category_cd = mct.mainte_category_cd AND mw.mainte_category_edition = mct.edition_no 
		LEFT JOIN mst_mainte_detail as mdt ON mw.mainte_detail_cd = mdt.mainte_detail_cd AND mw.mainte_detail_edition = mdt.edition_no 
)
-- 実績
, mainte_hst as (
	SELECT
		mhw.machine_no AS mainte_machine_no,
		mhw.mainte_date,
		mhw.mainte_no,
		
		mhw.mainte_layout_cd,
		mhw.mainte_layout_edition,
		mlh.layout_name,
		mlh.layout_header,
		
		mhw.tabIndex,

		mhw.mainte_category_cd,
		mhw.mainte_category_edition,
		mch.category_name,

		mhw.mainte_detail_cd,
		mhw.mainte_detail_edition,
		mdh.mainte_content_1,
		mdh.mainte_content_2,
		mdh.mainte_content_3,
		
		CASE 
			WHEN LENGTH(mhw.judge) <> 0 AND LENGTH(mhw.tabIndex) <> 0 THEN concat(mhw.tabIndex , '','' ,mhw.judge) 
			WHEN LENGTH(mhw.tabIndex) <> 0 THEN concat(mhw.tabIndex , '','')
			ELSE NULL
		END as judge,
		mhw.mainte_comment,
		mhw.user_id,
		mhw.date
	from
		mainte_work as mhw
	LEFT JOIN mst_mainte_layout_hst as mlh ON mhw.mainte_layout_cd = mlh.mainte_layout_cd AND mhw.mainte_layout_edition = mlh.edition_no 
	LEFT JOIN mst_mainte_category_hst as mch ON mhw.mainte_category_cd = mch.mainte_category_cd AND mhw.mainte_category_edition = mch.edition_no 
	LEFT JOIN mst_mainte_detail_hst as mdh ON mhw.mainte_detail_cd = mdh.mainte_detail_cd AND mhw.mainte_detail_edition = mdh.edition_no	
)

SELECT
	mt.machine_no,
	a.*
FROM
	machine_tbl AS mt
LEFT JOIN (
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
) a ON mt.machine_no = a.mainte_machine_no
ORDER BY ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), a.mainte_date, a.layout_name, a.tabindex
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "mainte_layout_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "layout_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトヘッダー", "can_calc": "0", "data_code": "layout_header", "data_name": "レイアウトヘッダー", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "layout_header", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_category_cd", "data_name": "グループコード", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "mainte_category_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "グループ名", "can_calc": "0", "data_code": "category_name", "data_name": "グループ名", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内容1", "can_calc": "0", "data_code": "mainte_content_1", "data_name": "内容1", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "mainte_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内容2", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "内容2", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1500", "can_calc": "0", "data_code": "mainte_content_3", "data_name": "内容3", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "mainte_content_3", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未", "can_calc": "0", "data_code": "judge", "data_name": "作業", "data_type": "string", "conv_table": [{"code": "1,", "disp": "", "item": ""}, {"code": "1,1", "disp": "レ", "item": "レ"}, {"code": "1,2", "disp": "〇", "item": "〇"}, {"code": "1,3", "disp": "✖", "item": "✖"}, {"code": "1,4", "disp": "A", "item": "A"}, {"code": "1,5", "disp": "T", "item": "T"}, {"code": "1,6", "disp": "C", "item": "C"}, {"code": "2,", "disp": "", "item": ""}, {"code": "2,1", "disp": "交換済み", "item": "交換済み"}], "data_class": "定期点検(記録簿)", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期検査記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "mainte_comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "user_id", "data_name": "点検者", "data_type": "string", "conv_table": [], "data_class": "定期点検(記録簿)", "field_name": "user_id", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '機器保守：定期点検(記録簿) @machineNos @facilityCd @fromDate @toDate使用', '2021-10-14 13:43:18', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (264, 'with
machine_tbl as (
	SELECT
		machine_no,
		machine_type_cd
	FROM
		mst_machine
	WHERE 
		machine_no in (@machineNos)
	AND
		is_disp =''1''
	AND
		is_del = ''0''
)
, mainte_work as (
	SELECT
		machine_no,
		mainte_date,
		mainte_no,
		
		mainte_layout_cd,
		mainte_layout_edition,
		
		detail_info ->> ''tableIndex'' AS tabIndex,
    CAST(detail_info ->> ''cate_cd'' AS INTEGER) AS mainte_category_cd,
		CAST(detail_info ->> ''cate_edi'' AS INTEGER) AS mainte_category_edition,
    CAST(detail_info ->> ''detail_cd'' AS INTEGER) AS mainte_detail_cd,
		CAST(detail_info ->> ''edition'' AS INTEGER) AS mainte_detail_edition,
		detail_info ->> ''judge'' as judge,
		detail_info ->> ''comment'' as mainte_comment,
		detail_info ->> ''user_id'' as user_id,
		detail_info ->> ''date'' as date
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
	AND	
		detail_info ->> ''tableIndex'' = ''2''
)
-- 予定
, mainte_tbl as (
	select
		mw.machine_no AS mainte_machine_no,
		mw.mainte_date,
		mw.mainte_no,
		
		mw.mainte_layout_cd,
		mw.mainte_layout_edition,
		mlt.layout_name,
		mlt.layout_header,

		mw.tabIndex,
		
		mw.mainte_category_cd,
		mw.mainte_category_edition,
		mct.category_name,
		
		mw.mainte_detail_cd,
		mw.mainte_detail_edition,
		mdt.mainte_content_1,
		mdt.mainte_content_2,
		mdt.mainte_content_3,
		
		null as judge,
		mw.mainte_comment,
		mw.user_id,
		mw.date
	from
		mainte_work as mw
		LEFT JOIN mst_mainte_layout as mlt ON mw.mainte_layout_cd = mlt.mainte_layout_cd AND mw.mainte_layout_edition = mlt.edition_no 
		LEFT JOIN mst_mainte_category as mct ON mw.mainte_category_cd = mct.mainte_category_cd AND mw.mainte_category_edition = mct.edition_no 
		LEFT JOIN mst_mainte_detail as mdt ON mw.mainte_detail_cd = mdt.mainte_detail_cd AND mw.mainte_detail_edition = mdt.edition_no 
)
-- 実績
, mainte_hst as (
	SELECT
		mhw.machine_no AS mainte_machine_no,
		mhw.mainte_date,
		mhw.mainte_no,
		
		mhw.mainte_layout_cd,
		mhw.mainte_layout_edition,
		mlh.layout_name,
		mlh.layout_header,
		
		mhw.tabIndex,

		mhw.mainte_category_cd,
		mhw.mainte_category_edition,
		mch.category_name,

		mhw.mainte_detail_cd,
		mhw.mainte_detail_edition,
		mdh.mainte_content_1,
		mdh.mainte_content_2,
		mdh.mainte_content_3,
		
		CASE 
			WHEN LENGTH(mhw.judge) <> 0 AND LENGTH(mhw.tabIndex) <> 0 THEN concat(mhw.tabIndex , '','' ,mhw.judge) 
			WHEN LENGTH(mhw.tabIndex) <> 0 THEN concat(mhw.tabIndex , '','')
			ELSE NULL
		END as judge,
		mhw.mainte_comment,
		mhw.user_id,
		mhw.date
	from
		mainte_work as mhw
	LEFT JOIN mst_mainte_layout_hst as mlh ON mhw.mainte_layout_cd = mlh.mainte_layout_cd AND mhw.mainte_layout_edition = mlh.edition_no 
	LEFT JOIN mst_mainte_category_hst as mch ON mhw.mainte_category_cd = mch.mainte_category_cd AND mhw.mainte_category_edition = mch.edition_no 
	LEFT JOIN mst_mainte_detail_hst as mdh ON mhw.mainte_detail_cd = mdh.mainte_detail_cd AND mhw.mainte_detail_edition = mdh.edition_no	
)

SELECT
	mt.machine_no,
	a.*
FROM
	machine_tbl AS mt
LEFT JOIN (
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
) a ON mt.machine_no = a.mainte_machine_no
ORDER BY ARRAY_POSITION(ARRAY[@machineNos], mt.machine_no), a.mainte_date, a.layout_name, a.tabindex
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "mainte_layout_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "layout_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトヘッダー", "can_calc": "0", "data_code": "layout_header", "data_name": "レイアウトヘッダー", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "layout_header", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_category_cd", "data_name": "グループコード", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "mainte_category_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "グループ名", "can_calc": "0", "data_code": "category_name", "data_name": "グループ名", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内容1", "can_calc": "0", "data_code": "mainte_content_1", "data_name": "内容1", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "mainte_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内容2", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "内容2", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1500", "can_calc": "0", "data_code": "mainte_content_3", "data_name": "内容3", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "mainte_content_3", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未", "can_calc": "0", "data_code": "judge", "data_name": "交換", "data_type": "string", "conv_table": [{"code": "1,", "disp": "", "item": ""}, {"code": "1,1", "disp": "レ", "item": "レ"}, {"code": "1,2", "disp": "〇", "item": "〇"}, {"code": "1,3", "disp": "✖", "item": "✖"}, {"code": "1,4", "disp": "A", "item": "A"}, {"code": "1,5", "disp": "T", "item": "T"}, {"code": "1,6", "disp": "C", "item": "C"}, {"code": "2,", "disp": "", "item": ""}, {"code": "2,1", "disp": "交換済み", "item": "交換済み"}], "data_class": "定期点検(交換部品)", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期交換部品記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "mainte_comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "user_id", "data_name": "作業者", "data_type": "string", "conv_table": [], "data_class": "定期点検(交換部品)", "field_name": "user_id", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '機器保守：定期点検(交換部品) @machineNos @facilityCd @fromDate @toDate使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
