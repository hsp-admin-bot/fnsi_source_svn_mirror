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
    facility_cd = (select facility_cd from ord_key_tbl)
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
    ord_key_tbl as okt,
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
    facility_cd = (select facility_cd from ord_key_tbl)
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
    facility_cd = (select facility_cd from ord_key_tbl)
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
    facility_cd = (select facility_cd from ord_key_tbl)
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
  mainte_layout_cd || '','' || to_char(mainte_date, ''YYYY/MM/DD'') not in (select mainte_layout_cd || '','' || to_char(mainte_date, ''YYYY/MM/DD'') from mainte_hst)
order by
  mainte_date, layout_name, mainte_category_idx, mainte_detail_idx
;' WHERE "sql_cd" = 107;