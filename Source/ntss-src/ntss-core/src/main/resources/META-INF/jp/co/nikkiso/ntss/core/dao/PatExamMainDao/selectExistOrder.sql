SELECT
  /*%expand "A" */*
FROM
  pat_exam_main A
WHERE
  A.exam_status = '0'
AND
  A.is_del = '0'
AND
  A.pat_id = /*patId*/0
AND
  A.reg_order_class = /*regOrderClass*/''
AND
  A.reg_exam_date = /*regExamDate*/'1970/01/01'
AND
  A.result_exam_date IS NULL
/*%if exclExamMainCd != null */
AND
  NOT (A.exam_main_cd = /*exclExamMainCd*/0)
/*%end */
-- add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関 start
AND
  A.phy_ord_class IS DISTINCT FROM '1'
ORDER BY reg_date DESC LIMIT 1
-- add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関 end
