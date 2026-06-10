select
  user_id
  , user_settings
  , is_provisional
  , reg_date
  , up_date
  , is_disp
  , is_del
  , pat_id
from
  mst_user
where
  facility_cd = /*facilityCd*/'1'
  and
  pat_id = /*patId*/1
;
