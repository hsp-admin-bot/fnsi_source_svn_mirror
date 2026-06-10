
select
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--pat_id
	pat_id,ind_kur_cd pat_name
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
from
	ord_main ord
where
  facility_cd = /*facilityCd*/'1'
  AND pat_id in /*patId*/(null)
  AND is_del = '0'
order by
/*%if "asc" != sortValue */
    ind_kur_cd DESC
/*%else*/
    ind_kur_cd ASC
/*%end*/
