  select
     A.medical_institution_cd,A.facility_name
  from
    sys_facility A
    where
    A.is_disp = '1'
;
