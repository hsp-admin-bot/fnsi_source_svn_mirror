UPDATE sys_data_set
SET sql = 'with machine_tbl as (
  select
    mm.*,
    mmt.machine_type
  from
    mst_machine as mm
      left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    machine_no = @machineNo
  and
    is_disp =''1''
  and
    is_del = ''0''


-- 予定
), mainte_layout_tbl as (
  select
    *
  from
    mst_mainte_layout
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_layout_work as (
  select
    mainte_category_idx,
    mainte_category_cd,
    mainte_layout_tbl.mainte_layout_cd,
    mainte_layout_tbl.edition_no
  from
    mainte_layout_tbl
      cross join lateral jsonb_array_elements_text(detail_info_1)
        with ordinality as tmp(mainte_category_cd, mainte_category_idx)

), mainte_category_tbl as (
  select
    *
  from
    mst_mainte_category
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_category_work as (
  select
    mainte_detail_idx,
    mainte_detail_cd,
    mainte_category_tbl.mainte_category_cd,
    mainte_category_tbl.edition_no,
    mainte_category_tbl.category_name
  from
    mainte_category_tbl
      cross join lateral jsonb_array_elements_text(detail)
        with ordinality as tmp(mainte_detail_cd, mainte_detail_idx)

), mainte_detail_tbl as (
  select
    mmd.*,

    mcw.edition_no as mainte_category_edition,
    mcw.category_name,

    mlw.mainte_category_idx,
    mcw.mainte_detail_idx,
    mlw.mainte_layout_cd,
    mlw.edition_no as mainte_layout_edition


  from
    mst_mainte_detail as mmd
      inner join mainte_category_work as mcw
        on (mcw.mainte_detail_cd::json->>''code'')::text = mmd.mainte_detail_cd::text

      inner join mainte_layout_work as mlw
        on (mlw.mainte_category_cd::json->>''cd'')::text = mcw.mainte_category_cd::text

  where
    mmd.facility_cd = (select facility_cd from machine_tbl)
  and
    mmd.is_disp = ''1''
  and
    mmd.is_del = ''0''


), mainte_plan_tbl as (
  select
    generate_series as mainte_date
  from
    generate_series(@fromDate::timestamp, @toDate::timestamp, ''1 day'')


), mainte_tbl as (
  select
    0 as mainte_no,
    mt.facility_cd,
    ''1''::text as mainte_class,
    mt.machine_no,
    null::integer as rec_no,
    mpt.mainte_date,
    mlt.mainte_layout_cd,
    mlt.edition_no as mainte_layout_edition,
    null::text as checker_id_1,
    null::text as checker_id_2,
    null::text as mainte_ans_1,
    null::text as mainte_ans_2,

    mt.com_format_cd || mt.machine_serial as machine_com_format_serial,
    mt.machine_serial,
    mt.machine_type,

    mlt.layout_name,

    mdt.mainte_detail_cd::text,
    mdt.edition_no::text as mainte_detail_edition,
    null::text as answer,
    null::text as comment,
    null::text as chekerId,
    null::text as regDate,
    mdt.mainte_category_cd,
    mdt.mainte_content_1,
    mdt.mainte_content_2,
    mdt.mainte_content_3,
    mdt.mainte_category_edition,
    mdt.category_name,

    mdt.mainte_category_idx,
    mdt.mainte_detail_idx

  from
      mainte_plan_tbl as mpt,
      machine_tbl as mt,
      mainte_layout_tbl as mlt,
      mainte_detail_tbl as mdt
  where 
     mlt.edition_no = mdt.mainte_layout_edition and 
     mlt.mainte_layout_cd = mdt.mainte_layout_cd


-- 実績
), mainte_layout_hst as (
  select
    *
  from
    mst_mainte_layout_hst
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_category_hst as (
  select
    *
  from
    mst_mainte_category_hst
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_detail_hst as (
  select
    *
  from
    mst_mainte_detail_hst
  where
    facility_cd = (select facility_cd from machine_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''



), mainte_work as (
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

), mainte_main_detail_hst as (
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

), mainte_main_category_hst as (
  select
    mainte_no,
    json_idx as mainte_category_idx,
    info->>''mainteCategoryCd'' as category_cd,
    info->>''editionNo'' as edition

  from
    mainte_work as mt
      cross join lateral jsonb_array_elements(mainte_category_cd)
        with ordinality as tmp(info, json_idx)


), mainte_hst as (
  select
    mw.mainte_no,
    mw.facility_cd,
    mw.mainte_class,
    mw.machine_no,
    mw.rec_no,
    mw.mainte_date,
    mw.mainte_layout_cd,
    mw.mainte_layout_edition,
    mw.checker_id_1,
    mw.checker_id_2,
    mw.mainte_ans_1,
    mw.mainte_ans_2,

    mt.com_format_cd || mt.machine_serial as machine_com_format_serial,
    mt.machine_serial,
    mt.machine_type,

    mlh.layout_name,

    mmdh.detail_cd as mainte_detail_cd,
    mmdh.edition as mainte_detail_edition,
    mmdh.judge,
    mmdh.comment,
    mmdh.user_id,
    mmdh.date,

    mdh.mainte_category_cd,
    mdh.mainte_content_1,
    mdh.mainte_content_2,
    mdh.mainte_content_3,

    mch.edition_no as mainte_category_edition,
    mch.category_name,

    mmch.mainte_category_idx,
    mmdh.mainte_detail_idx


  from
    mainte_work mw
      inner join machine_tbl as mt
        on mw.machine_no = mt.machine_no
      inner join mainte_layout_hst as mlh
        on mw.mainte_layout_cd = mlh.mainte_layout_cd and mw.mainte_layout_edition = mlh.edition_no
      inner join mainte_main_detail_hst as mmdh
        on mw.mainte_no = mmdh.mainte_no
      inner join mainte_detail_hst as mdh
        on mmdh.detail_cd = mdh.mainte_detail_cd::text and mmdh.edition = mdh.edition_no::text
      inner join mainte_category_hst as mch
        on mmdh.cate_cd = mch.mainte_category_cd::text and mmdh.cate_edi = mch.edition_no::text
      inner join mainte_main_category_hst as mmch
        on mmdh.mainte_no = mmch.mainte_no
        and mmdh.cate_cd = mmch.category_cd::text and mmdh.cate_edi = mmch.edition::text
)
select
  *
from
  mainte_hst
union all
select
  *
from
  mainte_tbl
where
  mainte_layout_cd || '','' || mainte_date not in (select mainte_layout_cd || '','' || mainte_date from mainte_hst)

order by
  mainte_date, layout_name, mainte_category_idx, mainte_detail_idx;',
detail = '[{"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "machine_com_format_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検詳細", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "mainte_layout_group_cd", "data_name": "レイアウトグループコード", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "mainte_layout_group_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "mainte_layout_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "judge", "data_name": "合否", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検詳細", "field_name": "judge", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "問題なしです。", "can_calc": "0", "data_code": "comment", "data_name": "点検コメント", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "comment", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "mainte_detail_cd", "data_name": "点検項目番号", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "mainte_detail_cd", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検見出し", "can_calc": "0", "data_code": "category_name", "data_name": "点検見出し", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "category_name", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検対象", "can_calc": "0", "data_code": "mainte_content_1", "data_name": "点検対象", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "mainte_content_1", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検基準", "can_calc": "0", "data_code": "mainte_content_2", "data_name": "点検基準", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "mainte_content_2", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "点検者", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "user_id", "data_name": "点検者", "data_type": "string", "conv_table": [], "data_class": "日常点検詳細", "field_name": "user_id", "disp_format": "", "filter_type": "Inspection", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/17", "can_calc": "0", "data_code": "date", "data_name": "個別点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検詳細", "field_name": "date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]',
report_class = '{"classes": [7]}' 
WHERE 
  sql_cd = 109;