select
  os.facility_cd
  ,os.ord_no
  ,os.treat_date
  ,os.kur_cd
  ,os.bed_cd
  ,os.pat_id
  ,os.treat_week
  ,mk.kur_name
from
  ord_schedule os
left join
  mst_kur mk
on
  os.kur_cd = mk.kur_cd
where
  os.facility_cd = /*facilityCd*/null
/*%if ordNoList.size() > 0 */
  and os.ord_no in /* ordNoList */(null)
/*%end */
order by os.pat_id, os.treat_date, os.kur_cd