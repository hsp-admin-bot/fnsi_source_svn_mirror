select
  /*%expand*/*
from
  mst_m_notice
where
  machine_record_cd not like 'G%'
and
  facility_cd = /* facilityCd */'000001'
order by
  machine_record_cd
;
