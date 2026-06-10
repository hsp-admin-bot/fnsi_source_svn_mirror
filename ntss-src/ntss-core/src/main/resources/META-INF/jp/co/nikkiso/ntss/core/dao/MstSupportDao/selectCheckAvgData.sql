WITH exam_item_config AS (
  SELECT
    elem ->> 'value' AS item_cd,
    elem ->> 'text' AS item_name,
    COALESCE(elem -> 'examflg', '["true", "true", "true"]'::jsonb) AS examflg
  FROM mst_medicine_support mms,
       LATERAL jsonb_array_elements((mms.detail_info ->> 'examItemAverage')::jsonb) AS elem
  WHERE mms.medicine_support_cd = /*cd*/'9'
),
exam_result_filtered AS (
  SELECT
    pem.facility_cd,
    pem.pat_id,
    pem.reg_order_class,
    pem.reg_date,
    pem.reg_exam_date,
    elem ->> 'item_cd' AS item_cd,
    elem ->> 'item_name' AS item_name,
    elem ->> 'result' AS result_value
  FROM pat_exam_main pem,
       LATERAL jsonb_array_elements(pem.exam_result_info::jsonb) AS elem
  WHERE pem.facility_cd = /*facilityCd*/'996996'
    AND pem.pat_id = /*patId*/33
    AND pem.is_del = '0'
    AND pem.reg_exam_date BETWEEN /*startDate*/'20200201' AND /*endDate*/'20210131'
    /*%if listExceptionPeriod != null && listExceptionPeriod.size() != 0*/
        /*%for exceptionPeriod : listExceptionPeriod */
        AND pem.reg_exam_date NOT BETWEEN /*exceptionPeriod.exceptionPeriodFrom*/'20200201' AND /*exceptionPeriod.exceptionPeriodTo*/'20210131'
        /*%end*/
    /*%end*/
    AND TRIM(elem ->> 'result') ~ '^[-+]?\d+(\.\d+)?$'
),
exam_valid AS (
  SELECT
    r.*,
    c.examflg
  FROM exam_result_filtered r
  JOIN exam_item_config c ON r.item_cd = c.item_cd
  WHERE
    (r.reg_order_class = '1' AND c.examflg ->> 0 = 'true') OR
    (r.reg_order_class = '2' AND c.examflg ->> 1 = 'true') OR
    (r.reg_order_class = '0' AND c.examflg ->> 2 = 'true')
),
gTab AS (
  SELECT
    facility_cd,
    pat_id,
    item_cd,
    item_name,
    ROUND(MAX(TO_NUMBER(COALESCE(NULLIF(result_value, ''), '0'), '9999999.99')), 2) AS maxResultValue,
    ROUND(MIN(TO_NUMBER(COALESCE(NULLIF(result_value, ''), '0'), '9999999.99')), 2) AS minResultValue,
    ROUND(AVG(TO_NUMBER(COALESCE(NULLIF(result_value, ''), '0'), '9999999.99')), 2) AS avgResultValue
  FROM exam_valid
  GROUP BY facility_cd, pat_id, item_cd, item_name
),
nTab AS (
  SELECT DISTINCT ON (item_cd)
    item_cd,
    ROUND(TO_NUMBER(COALESCE(NULLIF(result_value, ''), '0'), '9999999.99'), 2) AS result_value,
    reg_date,
    reg_exam_date
  FROM exam_valid
  ORDER BY item_cd, reg_exam_date DESC
)
SELECT
  gTab.facility_cd,
  gTab.pat_id,
  gTab.item_cd,
  gTab.item_name,
  gTab.maxResultValue,
  gTab.minResultValue,
  gTab.avgResultValue,
  nTab.result_value,
  nTab.reg_date,
  nTab.reg_exam_date
FROM gTab
LEFT JOIN nTab ON gTab.item_cd = nTab.item_cd
ORDER BY gTab.item_cd;
