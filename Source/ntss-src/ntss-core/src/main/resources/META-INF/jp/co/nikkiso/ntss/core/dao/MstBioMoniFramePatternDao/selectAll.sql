select
  /*%expand*/*
from
  mst_bio_moni_frame_pattern
where
  facility_cd = /*facility_cd*/'999000'
order by
  ctl_no
 ;
