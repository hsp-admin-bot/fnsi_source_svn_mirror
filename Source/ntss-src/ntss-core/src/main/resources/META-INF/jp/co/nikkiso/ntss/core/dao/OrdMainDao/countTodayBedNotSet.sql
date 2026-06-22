select
  count(*)
from
  ord_main
where
    facility_cd = /*facilityCd*/null
  and
    treat_date = to_char(CURRENT_DATE, 'yyyymmdd')
  and
    ind_bed_cd = 0
  and
    ind_kur_cd != 0
;