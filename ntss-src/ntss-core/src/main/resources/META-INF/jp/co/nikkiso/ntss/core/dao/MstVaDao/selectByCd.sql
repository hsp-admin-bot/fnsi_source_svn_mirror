SELECT
  A.va_cd
  , A.facility_cd
  , A.fn_va_cd
  , A.va_name
  , A.va_direct
  , A.in_hospital_cd_1
  , A.in_hospital_cd_2
  , A.is_disp
  , A.is_del
  , A.reg_date
  , A.up_date
FROM
  mst_va A
WHERE
  va_cd = /*vaCd*/'0'
AND
  is_del = '0'
;
