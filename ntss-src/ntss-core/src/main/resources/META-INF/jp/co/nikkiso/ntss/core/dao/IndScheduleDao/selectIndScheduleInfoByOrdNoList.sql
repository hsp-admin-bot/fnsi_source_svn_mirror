select
  B.facility_cd
  ,B.ord_no
  ,B.pat_id
  ,B.treat_date
  ,B.ind_kur_cd
  ,B.ind_bed_cd
  ,B.ind_treatment_cd
  ,B.ind_treat_start_time
  ,mk.kur_standard_start_time
  ,B.ind_cond_info->'1'->>'value' as ind_treatment_time
  ,B.rst_dialysis_state
  ,B.treat_week
from
  ord_main B
  left join
  mst_kur mk on B.facility_cd = mk.facility_cd and B.ind_kur_cd = mk.kur_cd
where
  B.facility_cd = /*facilityCd*/null
  and B.ord_no IN /*ordNoList*/(null)
