-- add 11010 スケジュール表出力時の処理が不足している gjn start
SELECT
  om.*
FROM
  ord_main om
WHERE
    om.pat_id IN /*patIds*/(NULL)
  and facility_cd = /*facilityCd*/null
  and om.is_del = '0'
  AND treat_date
  BETWEEN /*fromDate*/null AND /*toDate*/null
ORDER BY treat_date
--  add 11010 スケジュール表出力時の処理が不足している gjn end
