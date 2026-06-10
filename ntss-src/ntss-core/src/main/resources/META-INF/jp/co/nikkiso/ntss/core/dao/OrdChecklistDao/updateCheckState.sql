UPDATE
  ord_checklist
SET
/*%if "1" == originalCheck*/
  is_check = '0',
/*%end*/
/*%if "0" == originalCheck*/
  is_check = '1',
/*%end*/
  up_date = CURRENT_TIMESTAMP
WHERE
  ord_no = /*ordNo*/0
and
  facility_cd = /*facilityCd*/'0'
and
  is_check = /*originalCheck*/'1'
;
