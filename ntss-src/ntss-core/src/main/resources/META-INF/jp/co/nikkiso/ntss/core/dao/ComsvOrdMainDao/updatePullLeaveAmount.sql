update
  ord_main
set
  pull_leave_amount = to_number(/*param.pullLeaveAmount*/'0', '999.99'),
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  ord_no = /*param.ordNo*/1
;
