update mst_kur
set
  kur_name = /* mstKur.kurName */null,
  kur_start_time = /* mstKur.kurStartTime */null,
  kur_end_time = /* mstKur.kurEndTime */null,
  kur_standard_start_time = /* mstKur.kurStandardStartTime */null,
  in_hospital_cd_1 = /* mstKur.inHospitalCd_1 */null,
  is_del = /* mstKur.isDel */null,
  up_date = /*mstKur.upDate*/null,
  mst_user_authentication = /*mstKur.mstUserAuthentication*/null
where
  kur_cd = /*mstKur.kurCd*/null
;