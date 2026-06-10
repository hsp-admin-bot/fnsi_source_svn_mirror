select
  A.ctl_no
  , A.facility_cd
  , A.coop_cd
  , A.coop_cd_index
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , A.coop_version
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
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
  A.ctl_no = /*ctlNo*/'999999'
  AND A.is_del = '0'
