--ベッドグループのうち、特定のベッドを含むグループを抽出し、
--並び順が1番早いグループの並び順を返す
  select
    ms.index
  from
    mst_room_bed_group A   --テーブル名
    ,(
      select
        mss.facility_cd, ms.*, row_number() over() as index
      from
        mst_selector mss
      cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
        (
          code bigint,
          name text
        )
      where
        master_physical_name = 'mst_room_bed_group' --テーブル名
        /*%if facilityCd != null */
          and
          facility_cd = /* facilityCd*/'0'
        /*%end */
    ) ms
  where
    A.facility_cd = ms.facility_cd
  and
    A.room_bed_group_cd = ms.code --コードのカラム
  and
    A.is_del = '0'
  and
    A.is_disp = '1'
  and
    A.group_class = /* groupClass*/'0'
  and exists (
    select 1
    from jsonb_array_elements_text(bed_list) as bed
    where bed = /* bedCd*/'0'
  )
  order by
    ms.index
  limit 1
;
