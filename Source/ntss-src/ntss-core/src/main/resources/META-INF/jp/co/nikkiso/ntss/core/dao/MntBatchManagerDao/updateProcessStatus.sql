update mnt_batch_manager
set
/*%if param.status != null */
  status = /* param.status */'0',
/*%end*/
/*%if param.startTime != null */
  start_time = /* param.startTime */'1900-1-1 00:00:00',
/*%end*/
/*%if param.endTime != null */
  end_time = /* param.endTime */'2099-12-31 23:59:59',
/*%end*/
  up_date = CURRENT_TIMESTAMP
where
  ctl_no = /*param.ctlNo*/0
;