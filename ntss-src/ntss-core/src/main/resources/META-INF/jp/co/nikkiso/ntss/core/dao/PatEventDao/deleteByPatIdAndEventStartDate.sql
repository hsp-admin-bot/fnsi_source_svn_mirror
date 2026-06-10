UPDATE pat_event
SET is_del  = '1',
    up_date = CURRENT_TIMESTAMP
WHERE facility_cd = /*facilityCd*/null
  AND pat_id = /*patId*/null
  AND event_start_date = /*eventStartDate*/''
  AND is_del  = '0'
  AND (ord_no = 0 or ord_no is null )
;
