WITH all_keys AS (
  SELECT jsonb_object_keys(ind_cond_info) AS key
  FROM ord_main t
  WHERE t.is_del = '0'
    AND t.rst_dialysis_state = '0'

    /*%if null != patId*/
    AND t.pat_id = /*patId*/0
    /*%end*/

    /*%if null != facilityCd*/
    AND t.facility_cd = /*facilityCd*/'000000'
    /*%end*/

    AND t.treat_date >= /*treatDateFrom*/'00000000'

    /*%if null != treatDateTo*/
    AND t.treat_date <= /*treatDateTo*/'00000000'
    /*%end*/

    /*%if 0 != weeks.get(0)*/
    AND t.treat_week in /*weeks*/(0)
    /*%end*/

    /*%if 0 != treats.size()*/
    AND t.ind_treatment_cd in /*treats*/(0)
    /*%end*/

    /*%if 0 != kurs.size()*/
    AND t.ind_kur_cd in /*kurs*/(0)
  /*%end*/
)
SELECT key
FROM (
       SELECT DISTINCT key
       FROM all_keys
     ) subquery
ORDER BY CAST(key AS INTEGER);
