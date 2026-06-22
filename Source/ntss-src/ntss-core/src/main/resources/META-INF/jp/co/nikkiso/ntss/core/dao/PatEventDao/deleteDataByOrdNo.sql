UPDATE pat_event
SET is_del  = '1',
    up_date = CURRENT_TIMESTAMP
WHERE ord_no = /* ordNo */0;