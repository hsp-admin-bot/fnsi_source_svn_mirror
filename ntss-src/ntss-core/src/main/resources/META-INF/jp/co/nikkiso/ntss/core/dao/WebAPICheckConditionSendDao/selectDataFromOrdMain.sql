select
    pat_id,
    ind_bed_cd,
    ind_kur_cd,
    treat_date,
    facility_cd,
    ind_cond_info,
    ind_off_water_info
from
  ord_main
where
  ord_no = /*ordNo*/1
