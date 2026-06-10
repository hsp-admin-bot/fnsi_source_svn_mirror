select
  pat_id,
  medical_hst_info,
  in_out_visit_history_info,
  physical_info,
--  #11024 add MONGO(pat_unique_history)へのfacility_cd付加対応 卓 2024-08-22 start
  facility_cd,
--  #11024 add MONGO(pat_unique_history)へのfacility_cd付加対応 卓 2024-08-22 end
  is_del,
  up_date,
  reg_date,
  up_date as old_up_date_unique
from
  pat_unique
where
  pat_id = /*patId*/0
and
  is_del = '0'
;
