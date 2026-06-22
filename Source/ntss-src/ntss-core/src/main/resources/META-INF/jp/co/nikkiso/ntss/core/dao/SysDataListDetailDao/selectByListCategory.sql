select
  /*%expand "A" */*
from
  sys_data_list_detail A
where
  category_cd in /*listCategory*/(null)
order by
  A.data_list_detail_cd
;
