SELECT
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--pgd.pat_group_cd, pg.pat_group_name
	pgd.pat_id,pg.pat_group_name pat_name
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
FROM
	pat_group_detail as pgd
INNER JOIN
	pat_group as pg
ON
	pgd.pat_group_cd = pg.pat_group_cd
WHERE
	pgd.pat_id in /*patId*/(null)
AND
	pg.is_del = '0'
order by
/*%if "asc" != sortValue */
    pg.pat_group_name DESC
/*%else*/
	pg.pat_group_name ASC
/*%end*/
