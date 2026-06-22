select
  /*%expand "A" */*
from mnt_device_edge_manage A
where A.manage_no = /*manageNo*/0;