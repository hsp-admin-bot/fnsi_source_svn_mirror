UPDATE pat_exam_main
SET reg_exam_date       = CAST(tmp.reg_exam_date AS TIMESTAMP),
    order_exam_set_info = CAST(tmp.order_exam_set_info AS JSONB),
    exam_order_info     = CAST(tmp.exam_order_info AS JSONB),
    order_label_info    = CAST(tmp.order_label_info AS JSONB),
    is_order            = '1',
    up_date             = current_timestamp FROM
        (VALUES
        /*%for pem : patExamMainOfMergedList */
         (
             /* pem.examMainCd */null,
             /* pem.regExamDate */null,
             /* pem.orderExamSetInfo */null,
             /* pem.examOrderInfo */null,
             /* pem.orderLabelInfo */null
             )
        /*%if pem_has_next */
        /*# "," */
        /*%end */
        /*%end*/
        ) AS tmp ( exam_main_cd, reg_exam_date, order_exam_set_info, exam_order_info, order_label_info )
WHERE
    pat_exam_main.exam_main_cd = tmp.exam_main_cd;
