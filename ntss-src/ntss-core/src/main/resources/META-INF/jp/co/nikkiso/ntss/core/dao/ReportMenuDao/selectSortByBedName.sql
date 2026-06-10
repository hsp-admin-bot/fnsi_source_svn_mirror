SELECT
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--pat_id
	pat_id,mb.bed_name pat_name
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
FROM
	ord_main as od
INNER JOIN
	mst_bed as mb
ON
	od.ind_bed_cd = mb.bed_cd
AND od.facility_cd = mb.facility_cd
WHERE
	od.facility_cd = /*facilityCd*/'1'
AND
	od.pat_id in /*patId*/(null)
AND
	od.is_del = '0'
order by
/*%if "asc" != sortValue */
    mb.bed_name DESC
/*%else*/
	mb.bed_name ASC
/*%end*/
