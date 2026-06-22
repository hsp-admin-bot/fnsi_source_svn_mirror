UPDATE
  pat_treatment_pattern
SET
  ind_cond_info = jsonb_merge_recursive(/*toAddTreatCond*/'{}'::jsonb, ind_cond_info)
  /*%for cond : toDeleteTreatCondList*/
    -/* cond */'0'
  /*%end*/
WHERE
  ind_treatment_cd = /*ind_treatment_cd*/''
;