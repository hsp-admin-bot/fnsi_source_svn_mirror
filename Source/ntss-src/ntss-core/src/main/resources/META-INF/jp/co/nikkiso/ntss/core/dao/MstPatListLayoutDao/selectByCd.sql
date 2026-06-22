select
  /*%expand "A" */*
from 
  mst_pat_list_layout A
where 
  pat_list_layout_cd = /*patListLayoutCd*/0
and 
  is_disp = '1'
and 
  is_del = '0'
