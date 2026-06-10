select
  /*%expand "A" */*
from
  --テーブル名
  mst_bed A,
  (
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
	  /*%if facility_cd != null */  
      facility_cd = /* facility_cd*/'0'
    and
	  /*%end */
      master_physical_name = 'mst_bed' --テーブル名
  ) ms
where
  A.facility_cd = ms.facility_cd
and
  --コードのカラム
  A.bed_cd = ms.code
and
  A.is_del = '0'
and
  A.is_disp = '1'
--以下、有効なベッド(=machine_noが有効)を絞り込むために追加
and
  A.machine_no in
  (
    select
      machine_no
    from
      mst_machine
    where
      facility_cd = /*facility_cd*/'0'
      and
      is_disp = '1'
      and
      is_del = '0'
  )
order by
  ms.index
;