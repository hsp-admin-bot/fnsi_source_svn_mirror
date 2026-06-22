select
  /*%expand "A" */*
from
  mst_self_measure_result A
where
  A.facility_cd = /*facilityCd*/'0'
and
  is_disp = '1'
and
  is_del = '0'
and
  A.machine_info::jsonb @> ('[{"type_cd":"' || /* machineTypeCd */null || '"}]')::jsonb
order by
  self_measure_result_cd asc;
