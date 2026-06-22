SELECT  c.pat_id ,MAX(c.pat_name) as pat_name  FROM (
SELECT	DISTINCT pat_id,b.room_bed_group_cd as  pat_name
FROM
	ntss.ord_main as om
LEFT JOIN (SELECT
	MAX(bg.room_bed_group_cd) as room_bed_group_cd,bed_cd
FROM
	mst_room_bed_group bg
CROSS JOIN
	LATERAL jsonb_array_elements(bg.bed_list) tmp_best_list(bed_cd)
	where bg.group_class=/*groupClass*/'' and bg.facility_cd = /*facilityCd*/''  and bg.is_disp='1' and bg.is_del='0'
GROUP BY bed_cd  ORDER BY bed_cd ) b on om.ind_bed_cd = b.bed_cd::text::int
		where om.is_del = '0'
  AND om.facility_cd = /*facilityCd*/''
  AND om.pat_id in /*patId*/(null)
) c   GROUP BY c.pat_id  ORDER BY
 /*%if "asc" != sortValue */
    MAX(c.pat_name) DESC NULLS LAST
/*%else*/
    MAX(c.pat_name) ASC NULLS LAST
/*%end*/
