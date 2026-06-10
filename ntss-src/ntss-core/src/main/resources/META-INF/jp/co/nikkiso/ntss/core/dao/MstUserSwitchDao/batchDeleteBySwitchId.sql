delete
from
  mst_user_switch
where
  switch_id in(
  /*%for id : switchIdList */
    /*id*/0
    /*%if id_has_next */
--        /*# "," */
          ,
        /*%end */
  /*%end*/
  )
;
