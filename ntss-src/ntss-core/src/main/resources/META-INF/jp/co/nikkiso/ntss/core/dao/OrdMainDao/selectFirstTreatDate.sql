SELECT
  treat_date,
  ind_dw,
  rst_dialysis_state,
--   add 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関 start
  ind_cond_info
--   add 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関 end
FROM
  ord_main
WHERE
  is_del = '0'
/*%if null != patId*/
AND
  pat_id = /*patId*/0
/*%end*/
/*%if null != facilityCd*/
AND
  facility_cd = /*facilityCd*/'000000'
/*%end*/
AND
  treat_date >= /*treatDateFrom*/'00000000'
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
/*%if isIndFlag*/
AND
  rst_dialysis_state = '0'
/*%end*/

order by treat_date
LIMIT 1
