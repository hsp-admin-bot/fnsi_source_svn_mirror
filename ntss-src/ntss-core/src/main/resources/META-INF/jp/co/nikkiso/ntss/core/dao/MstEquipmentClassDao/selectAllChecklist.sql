select
  class_cd,
  class_name,
  class_type
from
  mst_equipment_class A
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
      facility_cd = /*facilityCd*/'0'
     and
      master_physical_name = 'mst_equipment_class' --テーブル名
  ) ms
where
  A.class_cd = ms.code
and
  A.is_del = '0'
and
  A.is_disp = '1'
order by
  ms.index
;
