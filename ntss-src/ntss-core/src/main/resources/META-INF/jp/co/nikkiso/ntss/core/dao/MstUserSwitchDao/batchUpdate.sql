UPDATE mst_user_switch
SET opt_status  = updates.optStatus,
    up_staff = /*updateUserId*/0,
    up_date = now()
From (
  Values
  /*%for mapping : entityList*/
  (
  /*mapping.switchId*/0,
  /*mapping.optStatus*/'0'
  )
  /*%if mapping_has_next */
  ,
  /*%end*/
  /*%end*/



) as updates(switchId,optStatus)
WHERE
    switch_id = updates.switchId
