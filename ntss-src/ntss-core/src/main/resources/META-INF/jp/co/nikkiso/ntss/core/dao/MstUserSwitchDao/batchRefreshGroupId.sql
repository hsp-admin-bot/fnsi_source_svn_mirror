UPDATE mst_user_switch
SET group_id  = /*groupId*/'',
  up_staff = /*updateUserId*/0,
  up_date = now()
WHERE
    group_id in (
    /*%for id : groupIdList */
        /*id*/0
        /*%if id_has_next */
--            /*# "," */
              ,
            /*%end */
      /*%end*/
    )
