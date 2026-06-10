select
  mfh.facility_cd as facility_cd,
  mfh.hash_value as hash_value,
  mfh.system_use_setting as system_use_setting,
  mfh.otp_failure_cnt as otp_failure_cnt
from
  mst_facility_hash mfh
where
  hash_value = /*hashValue*/'1'
union all
select
  '0' as facility_cd,
  '0' as hash_value,
  '0' as system_use_setting,
  5 as otp_failure_cnt
 where not exists
 (select *
  from mst_facility_hash
  where hash_value = /*hashValue*/'1');