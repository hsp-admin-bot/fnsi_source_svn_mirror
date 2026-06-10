SELECT EXISTS(
               SELECT 1
               FROM pat_exam_main pem
               WHERE EXISTS(
                             SELECT 1
                             FROM jsonb_array_elements(pem.exam_result_info) AS result
                             WHERE (result ->> 'item_cd')::BIGINT = (
                                 SELECT mei.exam_item_cd
                                 FROM mst_exam_item mei
                                 WHERE mei.facility_cd = /*facilityCd*/NULL
                                   AND mei.free_calc IS NULL
                                   AND mei.default_calc_exam_item_cd = /*defaultCalcExamItemCd*/NULL
                                   AND mei.is_disp = '1'
                                   AND mei.is_del = '0'
                                   AND mei.exam_class = '0'
                                   AND (CASE
                                            WHEN pem.reg_order_class = '1' THEN mei.dialysis_progress_flag <> '2'
                                            WHEN pem.reg_order_class IN ('0', '2') THEN mei.dialysis_progress_flag = '1'
                                     END)
                             )
                               AND pem.exam_main_cd = /*examMainCd*/NULL
                         )
           ) AS data_exists;