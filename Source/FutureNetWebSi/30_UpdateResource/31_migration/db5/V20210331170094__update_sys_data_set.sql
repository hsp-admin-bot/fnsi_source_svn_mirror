UPDATE sys_data_set 
SET SQL = 'with machine_tbl as (
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
), mainte_layout_group_tbl as (
select
*
from
mst_mainte_layout_group
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_tbl as (
select
*
from
mst_mainte_layout
where
facility_cd = (select facility_cd from machine_tbl)
and
layout_class = ''2''
and
(select machine_type_cd from machine_tbl)::text  in
(SELECT json_array_elements_text(
(SELECT to_json(type_info)))::text)
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
machine_no = @machineNo
and
mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
and
mainte_class = ''2''
and
mainte_layout_edition is null
and
is_disp = ''1''
and
is_del = ''0''


), mainte_tbl as (
select
mw.mainte_no,
mw.facility_cd,
mw.mainte_class,
mw.machine_no,
mw.rec_no,
mw.mainte_date,
mw.mainte_layout_group_cd,
mw.mainte_layout_group_edition,
mlt.mainte_layout_cd,
mw.mainte_layout_edition,
mw.checker_id_1,
mw.checker_id_2,
mw.mainte_ans_1,
mw.mainte_ans_2,

mt.machine_serial,
mt.machine_type,

mlgt.group_name,

mlt.layout_name,
mw.mainte_comment_1,
mw.mainte_comment_2,
mw.up_date

from
mainte_work as mw
inner join machine_tbl as mt
on mw.machine_no = mt.machine_no
inner join mainte_layout_group_tbl as mlgt
on mw.mainte_layout_group_cd = mlgt.mainte_layout_group_cd
inner join mainte_layout_tbl as mlt
on mlgt.layout_default = mlt.mainte_layout_cd

-- 実績
), mainte_layout_group_hst as (
select
*
from
mst_mainte_layout_group_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''

), mainte_layout_hst as (
select
*
from
mst_mainte_layout_hst
where
facility_cd = (select facility_cd from machine_tbl)
and
is_disp = ''1''
and
is_del = ''0''


), mainte_hst_work as (
select
*

from
mnt_mainte_main
where
machine_no = @machineNo
and
mainte_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
and
mainte_class = ''2''
and
mainte_layout_edition is not null
and
is_disp = ''1''
and
is_del = ''0''


), mainte_hst as (
select
mhw.mainte_no,
mhw.facility_cd,
mhw.mainte_class,
mhw.machine_no,
mhw.rec_no,
mhw.mainte_date,
mhw.mainte_layout_group_cd,
mhw.mainte_layout_group_edition,
mlh.mainte_layout_cd,
mhw.mainte_layout_edition,
mhw.checker_id_1,
mhw.checker_id_2,
mhw.mainte_ans_1,
mhw.mainte_ans_2,

mt.machine_serial,
mt.machine_type,

mlgh.group_name,

mlh.layout_name,
mhw.mainte_comment_1,
mhw.mainte_comment_2,
mhw.up_date

from
mainte_hst_work mhw
inner join machine_tbl as mt
on mhw.machine_no = mt.machine_no
inner join mainte_layout_group_hst as mlgh
on mhw.mainte_layout_group_cd = mlgh.mainte_layout_group_cd and mhw.mainte_layout_group_edition = mlgh.edition_no
inner join mainte_layout_hst as mlh
on mlgh.layout_default = mlh.mainte_layout_cd and mhw.mainte_layout_edition = mlh.edition_no

)
select
*
from
mainte_tbl
union all
select
*
from
mainte_hst

order by
mainte_date, layout_name',
detail = '[{"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "I7012104", "can_calc": "0", "data_code": "machine_com_format_serial", "data_name": "製造番号", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "machine_serial", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS-27", "can_calc": "0", "data_code": "machine_type", "data_name": "型式", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "mainte_date", "data_name": "点検日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検", "field_name": "mainte_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "mainte_layout_group_cd", "data_name": "レイアウトグループコード", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "mainte_layout_group_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウトグループ名", "can_calc": "0", "data_code": "group_name", "data_name": "レイアウトグループ名", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "group_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "mainte_layout_cd", "data_name": "レイアウトコード", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "mainte_layout_cd", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レイアウト名", "can_calc": "0", "data_code": "layout_name", "data_name": "レイアウト名", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "layout_name", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_1", "data_name": "定期点検記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "定期点検", "field_name": "mainte_ans_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "mainte_ans_2", "data_name": "定期交換部品記録総合判定", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "定期点検", "field_name": "mainte_ans_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_1", "data_name": "実施者", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "checker_id_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "checker_id_2", "data_name": "確認者", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "checker_id_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期検査記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_1", "data_name": "定期検査記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "mainte_comment_1", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "定期交換部品記録コメント：問題なしです。", "can_calc": "0", "data_code": "mainte_comment_2", "data_name": "定期交換部品記録コメント", "data_type": "string", "conv_table": [], "data_class": "定期点検", "field_name": "mainte_comment_2", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/16", "can_calc": "0", "data_code": "up_date", "data_name": "更新日", "data_type": "DateTime", "conv_table": [], "data_class": "定期点検", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]',
report_class = '{"classes": [7]}' 
WHERE
	sql_cd = '110'