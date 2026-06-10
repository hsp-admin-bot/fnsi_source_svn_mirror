UPDATE
  ord_main
SET
  ind_cond_info = /*toAddTreatCond*/'{}'::jsonb || ind_cond_info
  /*%for cond : toDeleteTreatCondList*/
    -/* cond */'0'
  /*%end*/
  /*%if isUpdateRst*/
  ,rst_cond_info = /*toAddTreatCond*/'{}'::jsonb || ind_cond_info
    /*%for cond : toDeleteTreatCondList*/
      -/* cond */'0'
    /*%end*/
  /*%end*/
WHERE
  ord_no in /*ordNoList*/()
;
