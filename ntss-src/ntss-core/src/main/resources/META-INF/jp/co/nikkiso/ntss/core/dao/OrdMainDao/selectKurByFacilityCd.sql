select ord_no,
       pat_id,
       ind_kur_cd,
       ind_bed_cd,
       treat_date,
       treat_week,
       rst_end_date,
       ind_treatment_cd,
       ind_treat_start_time
from ord_main A
where facility_cd = /*facilityCd*/'000000'
;
