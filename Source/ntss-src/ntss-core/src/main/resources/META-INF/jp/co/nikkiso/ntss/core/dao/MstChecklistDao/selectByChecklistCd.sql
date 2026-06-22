select
  /*%expand "A" */*
from
  mst_checklist A
where
/*%if null != checklistCd */
  checklist_cd=/*checklistCd*/0
/*%end*/
;