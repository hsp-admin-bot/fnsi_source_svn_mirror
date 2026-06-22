SELECT
  om.ord_no
FROM
  ord_main om
WHERE
    om.pat_id = /*patId*/0
  and facility_cd = /*facilityCd*/null
  and om.is_del = '0'
--   add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
  /*%if null != rstDialysisState*/
  and om.rst_dialysis_state > '0'
  /*%end*/
--   add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
  AND treat_date
  BETWEEN /*fromDate*/null AND /*toDate*/null
ORDER BY treat_date
