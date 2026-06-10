select
  master_physical_name
from
  mst_selector
where
  facility_cd = /*facility_cd*/null
and
  master_physical_name = 'mst_kur'
;