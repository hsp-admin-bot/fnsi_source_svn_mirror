SELECT
pem.result_exam_date,
pem.exam_result_info,
(
    SELECT mei.exam_item_cd
    FROM mst_exam_item AS mei
    WHERE mei.facility_cd = /*facilityCd*/NULL
      AND mei.is_disp = '1'
      AND mei.is_del = '0'
      AND mei.exam_class = '0'
      AND mei.default_calc_exam_item_cd = /*calcExamItemCd*/NULL
      AND (CASE
               WHEN pem.reg_order_class = '1' THEN mei.dialysis_progress_flag <> '2'
               WHEN pem.reg_order_class IN ('0', '2') THEN mei.dialysis_progress_flag = '1'
        END)
      AND mei.free_calc IS NULL
) AS exam_item_cd
FROM pat_exam_main AS pem
WHERE pem.facility_cd = /*facilityCd*/NULL
  AND pem.pat_id = /*patId*/0
  AND pem.result_exam_date IS NOT NULL
  AND pem.result_exam_date <= NOW()
  AND pem.result_exam_date >= (
    SELECT NOW() - (SELECT VALUE::INTEGER * INTERVAL '1 DAY'
                    FROM mst_facility_setting
                    WHERE facility_setting_no = '3012'
                      AND facility_cd = /*facilityCd*/NULL)
)
  AND EXISTS(
        SELECT 1
        FROM jsonb_array_elements(exam_result_info::JSONB) AS elem
        WHERE (elem ->> 'item_cd')::BIGINT = (
            SELECT mei.exam_item_cd
            FROM mst_exam_item AS mei
            WHERE mei.facility_cd = /*facilityCd*/NULL
              AND mei.is_disp = '1'
              AND mei.is_del = '0'
              AND mei.exam_class = '0'
              AND mei.default_calc_exam_item_cd = /*calcExamItemCd*/NULL
              AND (CASE
                       WHEN pem.reg_order_class = '1' THEN mei.dialysis_progress_flag <> '2'
                       WHEN pem.reg_order_class IN ('0', '2') THEN mei.dialysis_progress_flag = '1'
                END)
              AND mei.free_calc IS NULL
        )
          AND elem ->> 'result' IS NOT NULL
          AND elem ->> 'result' ~ '^[0-9０-９]+([．.][0-9０-９]+)?$'
          AND (
            CASE

                WHEN '14' = /*calcExamItemCd*/NULL THEN
                    ( TRANSLATE ( elem ->> 'result', '０１２３４５６７８９．', '0123456789.' ) ) :: NUMERIC BETWEEN 0.0
                        AND 9.0

                WHEN '7' = /*calcExamItemCd*/NULL THEN
                    ( TRANSLATE ( elem ->> 'result', '０１２３４５６７８９．', '0123456789.' ) ) :: NUMERIC BETWEEN 0
                        AND 60

                END
            )
    )
  AND pem.is_del = '0'
ORDER BY pem.result_exam_date DESC,
         CASE
             pem.reg_order_class
             WHEN '1' THEN 1
             WHEN '2' THEN 2
             WHEN '0' THEN 3
             ELSE 4
             END,
         pem.up_date DESC;