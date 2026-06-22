-- mod FNSI-改修内容 FutreNetWeb+SI課題管理No4816 趙 start
-- mod FNSI-改修内容 患者検索外結No5対応 趙 start
select distinct
  a.pat_id
from
  pat_group_detail as a left join pat_group as b on a.pat_group_cd = b.pat_group_cd
where
b.is_del = '0'
/*%if patIdList.size() > 0 */
  and a.pat_id in /* patIdList */(null)
/*%end */


  and a.pat_id in (
	select pat_id
	from pat_group_detail


	where pat_group_cd in (
	/*%for patGroupId : patGroupList */
		/* patGroupId */0
	/*%if patGroupId_has_next */
    ,
    /*%end */
	/*%end */
	)
	group by pat_id
	having count(distinct pat_group_cd) = /* patGroupList.size() */0

  )
-- SELECT
-- 	pat_id
-- FROM
-- 	(
-- 	SELECT DISTINCT
-- 	    A.pat_id,array_to_string(ARRAY(SELECT unnest(array_agg(A.pat_group_cd)) order by 1),',') as  group_cd_str,
-- 		COUNT ( A.pat_id ) AS groupcount
-- 	FROM
-- 		pat_group_detail AS A LEFT JOIN pat_group AS b ON A.pat_group_cd = b.pat_group_cd
-- 	WHERE
-- 		b.is_del = '0'
-- 		/*%if patIdList.size() > 0 */
--         AND A.pat_id IN /* patIdList */(null)
--         /*%end */
-- 		AND A.pat_id IN
-- 		(
-- 		  SELECT pat_id FROM pat_group_detail
-- 		  WHERE pat_group_cd IN (
-- 	      /*%for patGroupId : patGroupList */
-- 		  	/* patGroupId */0
-- 	      /*%if patGroupId_has_next */
--           ,
--           /*%end */
-- 	      /*%end */
-- 	      ) GROUP BY pat_id
-- 	    )
-- 	    GROUP BY
-- 		  A.pat_id
-- 	) PATGROUP
-- WHERE
-- 	groupcount = /* patGroupList.size() */0 and group_cd_str = /* patGroupStr */''
--   ;
-- mod FNSI-改修内容 患者検索外結No5対応 趙 end
-- mod FNSI-改修内容 FutreNetWeb+SI課題管理No4816 趙 end
