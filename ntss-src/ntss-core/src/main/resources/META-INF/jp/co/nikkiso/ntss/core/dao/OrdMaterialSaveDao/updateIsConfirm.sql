UPDATE
  ord_material_save
SET
  is_confirm = '1',
  up_date = now()
WHERE
  supplies_base_no = /*ordNo*/0
  /*%if patId != null */
  and pat_id = /*patId*/0
  /*%end */
;
