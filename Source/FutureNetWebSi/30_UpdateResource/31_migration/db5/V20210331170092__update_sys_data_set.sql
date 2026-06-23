UPDATE "ntss"."sys_data_set" SET "sql" = 'with machine_tbl as (
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
    to_char(mpt.mainte_date, ''YYYY/MM/DD'') as up_date,    

    mt.machine_serial,
    mt.machine_type,

    mlt.layout_name

  from
      mainte_plan_tbl as mpt,
      machine_tbl as mt,
      mainte_layout_tbl as mlt

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
    to_char(mw.up_date, ''YYYY/MM/DD'') as up_date,

    mt.machine_serial,
    mt.machine_type,

    mlh.layout_name

  from
    mainte_work mw
      inner join machine_tbl as mt
        on mw.machine_no = mt.machine_no
      inner join mainte_layout_hst as mlh
        on mw.mainte_layout_cd = mlh.mainte_layout_cd and mw.mainte_layout_edition = mlh.edition_no

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
  mainte_date, layout_name
;', "detail" = '[{"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "日常点検", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "mainte_layout_group_cd", "data_name": "レイアウトグループコード", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "mainte_layout_group_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "mainte_layout_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "総合判定", "data_type": "string", "conv_table": [{"code": "1", "disp": "合格", "item": "合格"}, {"code": "2", "disp": "点検途中", "item": "点検途中"}, {"code": "3", "disp": "不合格", "item": "不合格"}], "data_class": "日常点検", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "string", "conv_table": [], "data_class": "日常点検", "field_name": "up_date", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]',report_class = '{"classes": [7]}' WHERE "sql_cd" = 108;