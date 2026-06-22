SELECT
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--pat_id
	pat_id,(cast(ord_main.ind_medi_info->0->>'cd' as varchar )|| cast(ord_main.ind_equip_info->0->>'cd' as varchar )) pat_name
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
from
	ord_main
where
	facility_cd = /*facilityCd*/'1'
	AND pat_id in /*patId*/(null)
	AND is_del = '0'
order by
/*%if "asc" != sortValue */
	ord_main.ind_medi_info->0->>'cd' desc, ord_main.ind_equip_info->0->>'cd' desc
/*%else*/
	ord_main.ind_medi_info->0->>'cd' asc, ord_main.ind_equip_info->0->>'cd' asc
/*%end*/
