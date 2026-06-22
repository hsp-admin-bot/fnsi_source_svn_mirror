update ord_main
set
    ind_bed_cd = 0,
    ind_schedule_user_info = /*indScheduleUserInfo*/'{}'
where
    ord_no in /* ordNoList */(null)
;
