update pat_group
set
  in_hospital_cd_1 = /* patGroup.inHospitalCd_1 */null,
  up_date = to_timestamp(/* patGroup.upDate */null, 'YYYY-MM-DD HH24:MI:SS')
where
  pat_group_cd = /* patGroup.patGroupCd */null and
  facility_cd = /* facilityCd */null
;