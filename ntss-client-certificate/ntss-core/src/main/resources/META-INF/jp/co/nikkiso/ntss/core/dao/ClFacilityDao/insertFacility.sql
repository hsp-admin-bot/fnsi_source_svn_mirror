Insert into client_cer_facility
  (facility_cd,
  facility_name,
  facility_password,
  attempt_fail,
  reg_date,
  up_date,
  is_provisional,
  is_delete)
values
  (/*facilityCd*/NULL,
  /*facilityName*/NULL,
  /*facilityPassword*/NULL,
  /*attemptFail*/null,
  TO_TIMESTAMP(/*regDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
  TO_TIMESTAMP(/*regDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
  /*isProvisional*/1,
  '0')
