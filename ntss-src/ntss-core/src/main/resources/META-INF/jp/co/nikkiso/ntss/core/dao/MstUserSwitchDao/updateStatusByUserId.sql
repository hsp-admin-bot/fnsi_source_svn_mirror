UPDATE mst_user_switch
SET opt_status  = /*status*/'0',
    up_staff = /*updateUserId*/0,
    up_date = now()
WHERE
    user_id = /*userId*/0
