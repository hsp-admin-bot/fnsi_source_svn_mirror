
select
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--pat_id
	pat_id,is_infect pat_name
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
from
	pat_main
where
	facility_cd = /*facilityCd*/'1'
	AND pat_id in /*patId*/(null)
	AND is_del = '0'
order by
/*%if "asc" != sortValue */
	is_infect DESC
/*%else*/
	is_infect ASC
/*%end*/
