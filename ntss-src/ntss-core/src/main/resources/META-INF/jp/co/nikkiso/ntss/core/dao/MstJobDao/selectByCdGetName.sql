select
  job_cd,job_name
from
  mst_job
  WHERE
    facility_cd = /*facilityCd*/1
   and
   is_del = '0'
;
