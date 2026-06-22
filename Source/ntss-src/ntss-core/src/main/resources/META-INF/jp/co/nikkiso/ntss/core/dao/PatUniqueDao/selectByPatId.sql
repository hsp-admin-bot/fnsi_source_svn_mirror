select
  pat_id,
  medical_hst_info,
  in_out_visit_history_info,
  physical_info,
  is_del,
  up_date,
  reg_date,
  facility_cd
from
  pat_unique
where
  is_del = '0'
  and pat_id = /*patId*/0
;