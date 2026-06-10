update
    mst_comsv_setting
SET
    lcd_staff_list = /*lcdStaffList*/'{}',
    up_date = CURRENT_TIMESTAMP
WHERE
    comsv_cd = /* comsvCd */0
;