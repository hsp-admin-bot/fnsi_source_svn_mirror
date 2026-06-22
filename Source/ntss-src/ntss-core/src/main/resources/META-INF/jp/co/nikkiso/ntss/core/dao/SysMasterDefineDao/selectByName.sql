select
  /*%expand*/*
from
  sys_master_define
where
  master_physical_name = /*masterPhysicalName*/'mst_facility'
;
