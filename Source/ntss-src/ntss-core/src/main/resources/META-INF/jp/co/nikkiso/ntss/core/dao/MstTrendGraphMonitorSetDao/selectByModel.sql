select
  /*%expand "A" */*
from
  mst_trend_graph_monitor_set A
where
  A.facility_cd = /*facilityCd*/'999900'
  and
  A.model = /*model*/'002'
  and
  A.is_disp = '1'
  and
  A.is_del = '0'
-- add FNSI redmine 5702再修正 劉祥霖 start
  /*%if comFormatCd!=null */
-- add FNSI redmine 5702再修正 劉祥霖 end
  and
  A.com_format_cd = /*comFormatCd*/'D'
-- add FNSI redmine 5702再修正 劉祥霖 start
  /*%end */
-- add FNSI redmine 5702再修正 劉祥霖 end
  ;
