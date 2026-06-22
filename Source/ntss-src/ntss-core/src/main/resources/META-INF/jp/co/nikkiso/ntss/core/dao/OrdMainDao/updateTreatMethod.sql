update
  ord_main
set
  treat_item_cd = /*treatItemCd*/''
 ,up_date = CURRENT_TIMESTAMP
where
  ord_no in /*ordNo*/(1,2)
;
