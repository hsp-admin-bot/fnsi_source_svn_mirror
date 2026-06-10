select
  facility_cd
  , treat_date
  , treat_week
  , rst_dialysis_state
  , rst_bed_cd
  , rst_bed_name
  , rst_kur_cd
  , rst_kur_name
  , rst_treatment_cd
  , rst_treatment_name
from
  ord_main
where
  ord_no = /*ordNo*/1
and
  is_del = '0'
;
