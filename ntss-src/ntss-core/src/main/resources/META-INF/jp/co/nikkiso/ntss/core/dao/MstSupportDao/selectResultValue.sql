SELECT
    B1.resultValue,
    B1.item_cd,
    to_char( B1.regDate, 'yyyyMMdd' ) AS regDate
  FROM
    (
    SELECT
       elem ->> 'value' AS item_cd,
       coalesce(elem -> 'examflg', '["true", "true", "true"]'::jsonb) AS examflg
  FROM
    mst_medicine_support mms,
    LATERAL jsonb_array_elements((mms.detail_info ->> 'examItemCycling')::jsonb) AS elem
    WHERE
      mms.medicine_support_cd = /*cd*/'8'
      AND mms.facility_cd = /*facilityCd*/'996996'
      AND mms.is_del = '0'
    ) A1
    JOIN(
    SELECT
      jsonb_array_elements ( exam_result_info :: jsonb ) ->> 'item_cd' AS item_cd,
      jsonb_array_elements ( exam_result_info :: jsonb ) ->> 'result' AS resultValue,
      pem.reg_exam_date AS regDate, --#5660
      pem.reg_order_class
    FROM
      pat_exam_main pem
    WHERE
      pem.facility_cd = /*facilityCd*/'996996'
      AND pem.pat_id = /*patId*/33
      AND pem.is_del = '0'
      AND pem.reg_exam_date BETWEEN /*startDate*/'20200201' AND /*endDate*/'20210131'
--     add  5527 除外期間が適用されていない。張 start
    /*%if listExceptionPeriod != null && listExceptionPeriod.size() != 0*/
          /*%for exceptionPeriod : listExceptionPeriod*/
            AND pem.reg_exam_date NOT BETWEEN /*exceptionPeriod.exceptionPeriodFrom*/'20200201' AND /*exceptionPeriod.exceptionPeriodTo*/'20210131'
          /*%end*/
      /*%end*/
--     add  5527 除外期間が適用されていない。張 end
    )B1
    ON A1.item_cd = B1.item_cd
    WHERE (
        (B1.reg_order_class = '0' AND A1.examflg ->> 2 = 'true') OR
        (B1.reg_order_class = '1' AND A1.examflg ->> 0 = 'true') OR
        (B1.reg_order_class = '2' AND A1.examflg ->> 1 = 'true')
    )
  ORDER BY
    B1.regDate
