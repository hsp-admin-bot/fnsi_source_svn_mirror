UPDATE
  pat_treatment_pattern
SET
  ind_cond_info = jsonb_merge_recursive(/*toAddTreatCond*/'{}'::jsonb, ind_cond_info)
  /*%for cond : toDeleteTreatCondList*/
    -/* cond */'0'
  /*%end*/
  ,
  up_date = current_timestamp
WHERE
  pat_id = /*pat_id*/null
and
  ctl_no = /*ctl_no*/null
;
