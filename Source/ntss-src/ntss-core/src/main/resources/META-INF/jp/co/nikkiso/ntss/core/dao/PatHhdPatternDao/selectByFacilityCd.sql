select
  pat_id,
  revision,
  facility_cd,
  ind_treat_start_date,
  bed_cd,
  machine_no,
  ind_treatment_cd,
  ind_cond_info,
  ind_medi_info,
  reg_date,
  up_date
from
  pat_hhd_pattern A
where
  A.facility_cd = /*facility_cd*/null