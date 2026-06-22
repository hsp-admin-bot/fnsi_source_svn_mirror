update pat_group
set
  pat_group_name = /* patGroup.patGroupName */null,
  up_date = to_timestamp(/* patGroup.upDate */null, 'YYYY-MM-DD HH24:MI:SS')
where
  pat_group_cd = /*patGroupCd*/null and
  facility_cd = /* patGroup.facilityCd */null
;