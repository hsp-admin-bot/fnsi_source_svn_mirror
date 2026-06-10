--VA
  select
      va_cd,
      facility_cd,
      fn_va_cd,
      va_name,
      va_direct,
      in_hospital_cd_1,
      in_hospital_cd_2,
      is_disp,
      is_del,
      reg_date,
      up_date
  from
    mst_va A
      where
           A.facility_cd = /* params.facilityCd*/'0'
       and
           (A.is_del = '1' or A.is_disp = '0')
;

