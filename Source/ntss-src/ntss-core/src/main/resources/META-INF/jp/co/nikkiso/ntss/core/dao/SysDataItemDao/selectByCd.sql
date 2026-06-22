select
  /*%expand "A" */*
from
  sys_data_item A
where
  facility_cd = /*facility_cd*/'000001'
and
/*%if null != template_no */
  template_no = /*template_no*/1
  /*%if null != item_category */
and
  item_category = /*item_category*/1
    /*%if null != item_sub_category */
and
  item_sub_category = /*item_sub_category*/1
    /*%end*/
  /*%end*/
/*%else */
  1 = 1
/*%end*/
order by
  template_no, is_disp desc, disp_order, item_category, item_sub_category
;