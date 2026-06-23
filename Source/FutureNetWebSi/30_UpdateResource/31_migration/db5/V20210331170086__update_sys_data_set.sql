UPDATE "ntss"."sys_data_set" SET "sql" = 'with ord_key_tbl as (
  select
    ord_no,
    facility_cd,
    pat_id,
    to_timestamp( treat_date || ''000000'', ''yyyymmddhh24miss'') as from_date,
    to_timestamp( treat_date || ''235959'', ''yyyymmddhh24miss'') as to_date,
    case
      when coalesce(rst_dialysis_state, ''0'') = ''0'' then ind_bed_cd
      else rst_bed_cd
    end as bed_cd
  from
    ord_main
  where
    ord_no = @ordNo and is_del = ''0''

), bed_tbl as (
  select
    *
  from
    mst_bed
  where
    bed_cd = (select bed_cd from ord_key_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''

), machine_tbl as (
  select
    mm.*,
    mmt.machine_type
  from
    mst_machine as mm
      left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    machine_no = (select machine_no from bed_tbl)
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
    facility_cd = (select facility_cd from ord_key_tbl)
  and
    layout_class = ''1''
  and
    is_disp = ''1''
  and
    is_del = ''0''

), mainte_tbl as (
  select
    0 as mainte_no,
    okt.facility_cd,
    ''1''::text as mainte_class,
    mt.machine_no,
    null::integer as rec_no,
    okt.from_date as mainte_date,
    mlt.mainte_layout_cd,
    mlt.edition_no as mainte_layout_edition,
    null::text as checker_id_1,
    null::text as checker_id_2,
    null::text as mainte_ans_1,
    null::text as mainte_ans_2,
    to_char(okt.from_date, ''YYYY/MM/DD'') as up_date,

    mt.machine_serial as machine_com_format_serial,
    mt.machine_type,

    mlt.layout_name

  from
      ord_key_tbl as okt,
      machine_tbl as mt,
      mainte_layout_tbl as mlt

-- 実績
), mainte_layout_hst as (
  select
    *
  from
    mst_mainte_layout_hst
  where
    facility_cd = (select facility_cd from ord_key_tbl)
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
    mainte_date between (select from_date from ord_key_tbl) and (select to_date from ord_key_tbl)
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

    mt.machine_serial as machine_com_format_serial,
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
    mainte_layout_cd || '','' || to_char(mainte_date, ''YYYY/MM/DD'') not in (select mainte_layout_cd || '','' || to_char(mainte_date, ''YYYY/MM/DD'') from mainte_hst)
order by
  mainte_date, layout_name
;' WHERE "sql_cd" = 102;