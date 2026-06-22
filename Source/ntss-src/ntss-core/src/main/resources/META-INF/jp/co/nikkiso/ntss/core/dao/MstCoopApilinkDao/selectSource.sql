select
  A.ctl_no
  , A.facility_cd
  , A.coop_cd
  , A.coop_cd_index
  , A.coop_version
  , A.crud
  , A.direction
  , A.api_timing_io
  , A.api_timing_ba
  , A.api_timing_seq
  , A.api_uri
  , A.api_method
  , A.api_body
  , A.continue_api_status
  , A.after_api_status
  , A.is_del
  , A.user_id
  , A.reg_date
  , A.up_date
  , A.api_type
  , A.sql_setting
from
  mst_coop_apilink A
where
  A.coop_version = /*coopVersion*/''
  AND A.coop_cd = /*coopCd*/''
  AND A.ctl_no <= 0
  AND A.is_del = '0'
order by
  A.ctl_no
