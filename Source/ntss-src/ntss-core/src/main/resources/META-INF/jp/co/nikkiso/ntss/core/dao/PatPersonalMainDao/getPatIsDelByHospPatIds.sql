select hosp_pat_id, is_del
from pat_personal_main
where hosp_pat_id in /*hospPatIds*/(null)
  and facility_cd = /*facilityCd*/'000001'
;