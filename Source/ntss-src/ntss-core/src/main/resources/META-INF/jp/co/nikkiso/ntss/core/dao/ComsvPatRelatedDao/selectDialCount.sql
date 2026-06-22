select
  medical_care_info->>'dialysis_count' as dialysis_count
from
  pat_main
where
  pat_id = /*patId*/1
;
