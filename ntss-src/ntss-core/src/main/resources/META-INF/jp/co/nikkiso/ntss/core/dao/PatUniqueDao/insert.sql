insert into pat_unique (
  pat_id,
  medical_hst_info,
  in_out_visit_history_info,
  physical_info,
  up_date,
  reg_date,
  facility_cd
) values (
  /*pat.pat_id*/null,
  /*pat.medical_hst_info*/null,
  /*pat.in_out_visit_history_info*/null,
  /*pat.physical_info*/null,
  to_timestamp(/* pat.up_date */null, 'YYYY-MM-DD HH24:MI:SS'),
  to_timestamp(/* pat.reg_date */null, 'YYYY-MM-DD HH24:MI:SS'),
  /*pat.facility_cd*/null
);