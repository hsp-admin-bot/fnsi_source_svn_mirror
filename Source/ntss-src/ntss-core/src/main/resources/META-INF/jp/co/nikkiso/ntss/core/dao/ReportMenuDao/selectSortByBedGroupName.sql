SELECT
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--om.pat_id
	om.pat_id,bg.room_bed_group_name pat_name
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
FROM
	mst_room_bed_group bg
CROSS JOIN
	LATERAL jsonb_array_elements(bg.bed_list) tmp_best_list(child)
RIGHT JOIN
	ntss.ord_main as om
ON
	tmp_best_list.child::text = (om.ind_bed_cd)::text
where
  om.facility_cd = /*facilityCd*/'1'
  AND om.pat_id in/*patId*/(null)
  AND om.is_del= '0'
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--group by om.pat_id
group by om.pat_id,bg.room_bed_group_name
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
order by
/*%if "asc" != sortValue */
    bg.room_bed_group_name DESC
/*%else*/
    bg.room_bed_group_name ASC
/*%end*/
