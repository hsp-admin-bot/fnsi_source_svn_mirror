update ord_main
set
    ind_bed_cd = 0,
    up_user_id = /*userId*/null,
    up_ind_user_id = /*indUserId*/null,
    up_date = CURRENT_TIMESTAMP
where
    ord_no in /* ordNoList */(null)
;
