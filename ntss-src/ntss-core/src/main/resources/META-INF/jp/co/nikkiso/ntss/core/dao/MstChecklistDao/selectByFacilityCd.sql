select
  /*%expand "A" */*
from
  mst_checklist A
where
/*%if null != facility_cd */
  A.facility_cd=/*facility_cd*/'000000'
/*%end*/
/*%if null != is_del */
  /*%if null != facility_cd */
and
  /*%end*/
  A.is_del=/*is_del*/null
/*%end*/
-- add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
order by A.checklist_cd desc
-- add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
;
