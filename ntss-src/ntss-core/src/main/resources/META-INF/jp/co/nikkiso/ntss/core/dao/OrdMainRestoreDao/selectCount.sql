select count(del_date)
  from ord_main_restore
 where ord_no = /*ordNo*/null
   and del_date > /*delDate*/null
