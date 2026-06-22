select
  /*%expand*/*
from
  sys_master_define
where
/*%if userType == null || userType != @jp.co.nikkiso.ntss.core.constant.CoreConstant$UserType@NIKKISO */
  disp_class = /* @jp.co.nikkiso.ntss.core.constant.CoreConstant$DispClass@NORMAL */'2'
/*%end*/
order by
  disp_order
;
