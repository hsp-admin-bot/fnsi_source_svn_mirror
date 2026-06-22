-- add 9664 by kangjie 20240513 start
SELECT
 treatment.device_mode as ind_device_mode
 ,treatment.treatment_condition_setting as treatment_condition_setting
FROM
  ord_main t
  left join mst_treatment treatment on treatment.treatment_cd = t.ind_treatment_cd
WHERE
  t.is_del = '0'
  AND
  t.rst_dialysis_state = '0'
/*%if null != patId*/
AND
  t.pat_id = /*patId*/0
/*%end*/
-- mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関
/*%if null != facilityCd*/
AND
  t.facility_cd = /*facilityCd*/'000000'
/*%end*/
AND
  t.treat_date >= /*treatDateFrom*/'00000000'
/*%if null != treatDateTo*/
AND
  t.treat_date <= /*treatDateTo*/'00000000'
/*%end*/
/*%if 0 != weeks.get(0)*/
AND
  t.treat_week in /*weeks*/(0)
/*%end*/
/*%if 0 != treats.size()*/
AND
  t.ind_treatment_cd in /*treats*/(0)
/*%end*/
/*%if 0 != kurs.size()*/
AND
  t.ind_kur_cd in /*kurs*/(0)
/*%end*/

ORDER BY t.treat_date asc, t.ord_no asc
limit 1
-- add 9664 by kangjie 20240513 end
