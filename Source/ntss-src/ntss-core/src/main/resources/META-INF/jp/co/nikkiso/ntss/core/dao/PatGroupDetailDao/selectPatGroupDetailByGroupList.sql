select distinct
  a.pat_id
from
  pat_group_detail as a left join pat_group as b on a.pat_group_cd = b.pat_group_cd
where
b.is_del = '0'
/*%if patIdList.size() > 0 */
  and a.pat_id in /* patIdList */(null)
/*%end */

/*%if dSearchType == 1 && dSearchPatGroupList.size() > 0 */
and (
  /*%for patGroupId : dSearchPatGroupList */
	a.pat_group_cd = /* patGroupId */0

    /*%if patGroupId_has_next */
    or
    /*%end */
  /*%end */
  )
/*%elseif dSearchPatGroupList.size() > 0 */
and a.pat_id in (
	select pat_id
	from pat_group_detail


	where pat_group_cd in (
	/*%for patGroupId : dSearchPatGroupList */
		/* patGroupId */0
	/*%if patGroupId_has_next */
    ,
    /*%end */
	/*%end */
	)
	group by pat_id
	having count(distinct pat_group_cd) = /* dSearchPatGroupList.size() */0

  )
/*%end */

/*%if sSearchType == 1 && sSearchPatGroupList.size() > 0 */
and (
  /*%for patGroupId : sSearchPatGroupList */
	a.pat_group_cd = /* patGroupId */0

    /*%if patGroupId_has_next */
    or
    /*%end */
  /*%end */
  )
/*%elseif sSearchPatGroupList.size() > 0 */
and a.pat_id in (
	select pat_id
	from pat_group_detail


	where pat_group_cd in (
	/*%for patGroupId : sSearchPatGroupList */
		/* patGroupId */0
	/*%if patGroupId_has_next */
    ,
    /*%end */
	/*%end */
	)
	group by pat_id
	having count(distinct pat_group_cd) = /* sSearchPatGroupList.size() */0

  )
/*%end */

