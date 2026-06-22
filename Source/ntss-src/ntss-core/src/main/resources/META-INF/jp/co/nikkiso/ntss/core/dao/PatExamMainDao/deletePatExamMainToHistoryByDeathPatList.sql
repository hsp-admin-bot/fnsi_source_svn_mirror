WITH updatesAll AS (
    SELECT facility_cd, exam_main_cd
    FROM (
             VALUES
             (null, 0)
             /*%for dp : deathPatList */
              ,(
                 /*dp.facilityCd*/null,
                 /*dp.examMainCd*/0
             )
             /*%end*/
         ) AS t(facility_cd, exam_main_cd)
),
updates AS (SELECT DISTINCT facility_cd, exam_main_cd FROM updatesAll),
inserted_data AS (
INSERT INTO pat_exam_main_hst (
                               exam_main_cd
                              ,pat_id
                              ,facility_cd
                              ,ord_no
                              ,fn_pat_id
                              ,reg_exam_date
                              ,reg_order_class
                              ,exam_status
                              ,order_comment
                              ,order_exam_set_info
                              ,exam_order_info
                              ,order_label_info
                              ,data_gen_class
                              ,result_exam_date
                              ,result_comment
                              ,exam_result_info
                              ,cop_order_no1
                              ,cop_order_no2
                              ,is_lock
                              ,ind_user_id
                              ,is_del
                              ,reg_date
                              ,reg_staff
                              ,up_date
                              ,up_staff
                              ,is_order
                              ,phy_ord_class)
SELECT
    pem.exam_main_cd
     ,pem.pat_id
     ,pem.facility_cd
     ,pem.ord_no
     ,pem.fn_pat_id
     ,pem.reg_exam_date
     ,pem.reg_order_class
     ,pem.exam_status
     ,pem.order_comment
     ,pem.order_exam_set_info
     ,pem.exam_order_info
     ,pem.order_label_info
     ,pem.data_gen_class
     ,pem.result_exam_date
     ,pem.result_comment
     ,pem.exam_result_info
     ,pem.cop_order_no1
     ,pem.cop_order_no2
     ,pem.is_lock
     ,pem.ind_user_id
     ,pem.is_del
     ,pem.reg_date
     ,pem.reg_staff
     ,pem.up_date
     ,pem.up_staff
     ,pem.is_order
     ,pem.phy_ord_class
FROM pat_exam_main pem, updates AS u
WHERE
        pem.facility_cd = /*facilityCd*/null AND
        pem.facility_cd = u.facility_cd AND
        pem.exam_main_cd = u.exam_main_cd)
DELETE FROM pat_exam_main
    USING updates u
WHERE
    pat_exam_main.facility_cd = /*facilityCd*/null AND
    pat_exam_main.facility_cd = u.facility_cd AND
    pat_exam_main.exam_main_cd = u.exam_main_cd
RETURNING pat_exam_main.*
