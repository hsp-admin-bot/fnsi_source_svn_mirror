WITH updatesAll AS (
    select
        /*%expand "A" */*
    from
        pat_rad_main A
    WHERE
      A.facility_cd = /*facilityCd*/'000000'
      /*%if personalMainList != null && personalMainList.size() != 0*/
      AND (
        /*%for pat : personalMainList*/
        (A.pat_id = /*pat.pat_id*/0 AND A.reg_rad_date::date >= CAST(/*pat.die_date*/'' AS DATE))
        /*%if pat_has_next */
        /*# "or" */
        /*%end*/
        /*%end*/
        )
      /*%end*/
),
updates AS (SELECT DISTINCT facility_cd, rad_result_cd FROM updatesAll),
inserted_data AS (
INSERT INTO pat_rad_main_hst (
                              rad_result_cd
                             ,pat_id
                             ,facility_cd
                             ,fn_pat_id
                             ,reg_rad_date
                             ,reg_order_class
                             ,rad_status
                             ,order_rad_set_info
                             ,cop_order_no1
                             ,cop_order_no2
                             ,is_lock
                             ,ind_user_id
                             ,is_del
                             ,reg_date
                             ,reg_staff
                             ,up_date
                             ,up_staff)
SELECT
    prm.rad_result_cd
     ,prm.pat_id
     ,prm.facility_cd
     ,prm.fn_pat_id
     ,prm.reg_rad_date
     ,prm.reg_order_class
     ,prm.rad_status
     ,prm.order_rad_set_info
     ,prm.cop_order_no1
     ,prm.cop_order_no2
     ,prm.is_lock
     ,prm.ind_user_id
     ,prm.is_del
     ,prm.reg_date
     ,prm.reg_staff
     ,prm.up_date
     ,prm.up_staff
FROM pat_rad_main prm, updates AS u
WHERE
        prm.facility_cd = /*facilityCd*/null AND
        prm.facility_cd = u.facility_cd AND
        prm.rad_result_cd = u.rad_result_cd)
DELETE FROM pat_rad_main
    USING updates u
WHERE
    pat_rad_main.facility_cd = /*facilityCd*/null AND
    pat_rad_main.facility_cd = u.facility_cd AND
    pat_rad_main.rad_result_cd = u.rad_result_cd
RETURNING pat_rad_main.*
