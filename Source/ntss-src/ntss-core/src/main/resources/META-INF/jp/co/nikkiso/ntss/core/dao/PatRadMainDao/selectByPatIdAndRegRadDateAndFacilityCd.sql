SELECT
    rad_result_cd,
    pat_id,
    facility_cd,
    fn_pat_id,
    reg_rad_date,
    reg_order_class,
    rad_status,
    order_rad_set_info,
    cop_order_no1,
    cop_order_no2,
    is_lock,
    ind_user_id,
    is_del,
    reg_date,
    reg_staff,
    up_date,
    up_staff
FROM pat_rad_main
WHERE is_del = '0'
AND pat_id = /* patId */null
AND to_char(reg_rad_date,'YYYY-MM-DD') = /* regRadDate */null
AND facility_cd = /* facilityCd */null
