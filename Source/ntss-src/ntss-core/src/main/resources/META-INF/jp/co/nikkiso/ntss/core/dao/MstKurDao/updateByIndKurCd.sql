update
  ord_main
set
  ind_kur_cd = /*kur_cd*/null,
  ind_treat_start_time = null
where
  ord_no in (
  select
    ord_no
  from
    ord_main
  where
    facility_cd = /*facility_cd*/null
  and
    ind_kur_cd in /*kurList*/(null)
)
;