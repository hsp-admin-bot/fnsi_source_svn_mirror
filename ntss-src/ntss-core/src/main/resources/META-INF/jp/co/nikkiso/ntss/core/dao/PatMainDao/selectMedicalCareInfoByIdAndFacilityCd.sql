select medical_care_info
from pat_main
where is_del = '0'
  and facility_cd = /*facilityCd*/'000001'
  and pat_id = /*patId*/'000001'
;
