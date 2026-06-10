SELECT
  Round( AVG ( to_number( result_value, '9999999999' ) ), 2 ) avg_value
FROM
  (
  SELECT
    jsonb_array_elements ( exam_result_info :: jsonb ) ->> 'result' AS result_value,
    jsonb_array_elements ( exam_result_info :: jsonb ) ->> 'item_cd' AS item_cd
  FROM
    pat_exam_main pem
  WHERE
    pem.facility_cd = /*facilityCd*/'996996'
    AND pem.pat_id = /*patId*/33
    AND pem.is_del = '0'
    AND pem.reg_date BETWEEN /*startDate*/'20200201' AND /*endDate*/'20210131'
--     add  5527 除外期間が適用されていない。張 start
    /*%if listExceptionPeriod != null && listExceptionPeriod.size() != 0*/
          /*%for exceptionPeriod : listExceptionPeriod*/
                AND pem.reg_date NOT BETWEEN /*exceptionPeriod.exceptionPeriodFrom*/'20200201' AND /*exceptionPeriod.exceptionPeriodTo*/'20210131'
          /*%end*/
      /*%end*/
--     add  5527 除外期間が適用されていない。張 end
  ) tab
WHERE
  item_cd = /*cd*/'24'
