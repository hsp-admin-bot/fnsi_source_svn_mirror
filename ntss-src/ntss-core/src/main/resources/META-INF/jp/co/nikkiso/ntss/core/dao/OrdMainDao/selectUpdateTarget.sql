SELECT
   /*%expand*/*
FROM
  ord_main
WHERE
-- mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関
  is_del = '0'
/*%if null != patId*/
AND
  pat_id = /*patId*/0
/*%end*/
-- mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関
/*%if null != facilityCd*/
AND
  facility_cd = /*facilityCd*/'000000'
/*%end*/
AND
  treat_date >= /*treatDateFrom*/'00000000'
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
/*%if targetDialysisState != null*/
AND
  rst_dialysis_state = /*targetDialysisState*/'0'
/*%end*/
ORDER BY treat_date, ord_no
