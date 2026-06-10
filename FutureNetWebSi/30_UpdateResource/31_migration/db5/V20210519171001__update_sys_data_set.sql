UPDATE sys_data_set 
SET SQL = 'with machine_tbl as (
select
mm.*,
mmt.machine_type
from
mst_machine as mm
left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
where 
machine_no = 344
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
machine_no = 344
and
mainte_date between date_trunc(''day'', ''2021-4-26'' ::timestamp ) and date_trunc(''day'', ''2021-05-19'' ::timestamp) + ''1 days - 1 milliseconds''
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
on (mlt.mainte_layout_cd::text  in (SELECT json_array_elements_text(
(SELECT to_json(mlgt.layout_list)))::text))

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
machine_no = 344
and
mainte_date between date_trunc(''day'',''2021-04-26'' ::timestamp ) and date_trunc(''day'',''2021-04-26'' ::timestamp) + ''1 days - 1 milliseconds''
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
on mlh.mainte_layout_cd ::text in
(SELECT json_array_elements_text(
(SELECT to_json(mlgh.layout_list)))::text) and mhw.mainte_layout_edition = mlh.edition_no
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
mainte_date, layout_name'
WHERE
	sql_cd = '110'