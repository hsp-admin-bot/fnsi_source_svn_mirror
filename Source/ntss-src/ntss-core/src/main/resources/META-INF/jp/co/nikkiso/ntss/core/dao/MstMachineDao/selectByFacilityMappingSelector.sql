select
  /*%expand "A" */*
from
  mst_machine A, (
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
      master_physical_name = 'mst_machine' --テーブル名
      /*%if facilityCd != null */
      and
      facility_cd = /*facilityCd*/'0'
      /*%end */
  ) ms
where
  	A.facility_cd = ms.facility_cd
    and
    A.machine_no = ms.code --コードのカラム
    and
    A.is_del = '0'
    and
    A.is_disp = '1'
ORDER BY
	ms.index
;
