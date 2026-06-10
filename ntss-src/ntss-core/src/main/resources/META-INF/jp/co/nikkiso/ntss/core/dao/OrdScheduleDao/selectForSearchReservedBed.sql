select
  /*%expand "osmk"*/*
from
  (
    select
      os.*,
      os.treat_date || mk.kur_standard_start_time treat_datetime
    from
      ord_schedule os, 
      (
        select
          *
        from
          mst_kur
        where
          is_del = '0'
      ) mk
    where
      os.facility_cd = /*facilityCd*/null
    and
      os.facility_cd = mk.facility_cd
    and
      os.kur_cd = mk.kur_cd
    and
      os.bed_cd = /*bedCd*/null
		and
      (
          os.pat_id <> /*patId*/null
        or
          (
              os.pat_id = /*patId*/null
            and
              os.ord_no not in /*ordNoList*/(null)
          )
      )
  ) osmk
where
  osmk.treat_datetime >= /*searchStartDatetime*/null
/*%if null != searchEndDatetime*/
and
  osmk.treat_datetime <= /*searchEndDatetime*/null
/*%end*/
order by
  osmk.treat_datetime