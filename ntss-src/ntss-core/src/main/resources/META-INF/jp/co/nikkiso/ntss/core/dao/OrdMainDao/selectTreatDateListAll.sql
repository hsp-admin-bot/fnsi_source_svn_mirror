SELECT
  ord_no, treat_date
FROM
  ord_main
WHERE
  pat_id = /*patId*/0
/*%if null != facilityCd*/
AND
  facility_cd = /*facilityCd*/'000000'
/*%end*/
  -- modify 10266 by kangjie 20240712 start
/*%if null != treatDateFrom*/
AND
  treat_date >= /*treatDateFrom*/'00000000'
/*%end*/
  -- modify 10266 by kangjie 20240712 end
/*%if null != treatDateTo*/
AND
  treat_date <= /*treatDateTo*/'00000000'
/*%end*/
/*%if 0 != weeks.get(0)*/
AND
  treat_week in /*weeks*/(0)
/*%end*/
/*%if 0 != treats.size()*/
AND
  ind_treatment_cd in /*treats*/(0)
/*%end*/
/*%if 0 != kurs.size()*/
AND
  ind_kur_cd in /*kurs*/(0)
/*%end*/
ORDER BY treat_date, ord_no
