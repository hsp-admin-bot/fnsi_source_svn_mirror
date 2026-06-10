select
  /*%expand*/*
from
  mst_facility
where
  mst_facility.facility_cd not in (
  select a.facility_cd
  from
    mnt_facility_cancel_manage a
  where
    a.proc_status = '9'
  )
  /*# orderBy */
