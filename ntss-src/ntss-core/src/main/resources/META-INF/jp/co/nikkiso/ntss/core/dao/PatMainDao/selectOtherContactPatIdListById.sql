select pat_id_dst
from pat_name_identification
where pat_id_src= /* pat_id */1
and facility_cd_dst = /*dstfacility_cd*/null
and facility_cd_src = /*srcfacility_cd*/null
and pat_id_dst is not NULL
and approve = '1'
and is_open = '1'
;
