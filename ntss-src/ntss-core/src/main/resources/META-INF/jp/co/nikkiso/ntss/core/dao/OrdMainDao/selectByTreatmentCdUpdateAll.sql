SELECT
  /*%expand "A" */*
FROM
  ord_main A
WHERE
  facility_cd = /*facilityCd*/'000000'
/*%if null != treats*/
AND
  ind_treatment_cd = /*treats*/'0'
/*%end*/
/*%if isNotSent*/
and
  A.rst_dialysis_state = '0'
/*%end*/
and A.treat_date >= to_char(now(), 'YYYYMMDD')
ORDER BY treat_date, ord_no
