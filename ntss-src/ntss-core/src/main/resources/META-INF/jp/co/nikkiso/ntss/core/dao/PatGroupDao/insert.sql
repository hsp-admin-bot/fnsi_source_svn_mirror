insert into pat_group (
  pat_group_cd,
  pat_group_name,
  facility_cd,
  up_date,
  reg_date
) values (
  /*patGroup.patGroupCd*/null,
  /*patGroup.patGroupName*/null,
  /*patGroup.facilityCd*/null,
  to_timestamp(/* patGroup.upDate */null, 'YYYY-MM-DD HH24:MI:SS'),
  to_timestamp(/* patGroup.regDate */null, 'YYYY-MM-DD HH24:MI:SS')
);