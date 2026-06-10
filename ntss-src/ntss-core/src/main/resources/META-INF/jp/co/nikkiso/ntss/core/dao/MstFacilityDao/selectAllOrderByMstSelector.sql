select
  /*%expand "A" */*
from
  mst_facility A
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
    master_physical_name = 'mst_facility'
  ) ms
where
  A.facility_cd = ms.name
order by
  ms.index
;
