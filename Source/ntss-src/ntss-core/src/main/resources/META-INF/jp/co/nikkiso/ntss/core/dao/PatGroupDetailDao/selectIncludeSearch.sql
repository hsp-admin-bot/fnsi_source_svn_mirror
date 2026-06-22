select distinct
  a.pat_id
from
  pat_group_detail as a left join pat_group as b on a.pat_group_cd = b.pat_group_cd
where
b.is_del = '0' 
/*%if patIdList.size() > 0 */
  and a.pat_id in /* patIdList */(null)
/*%end */

   and (
  /*%for patGroupId : patGroupList */
	a.pat_group_cd = /* patGroupId */0
   
    /*%if patGroupId_has_next */
    or
    /*%end */
  /*%end */
  )
  ;