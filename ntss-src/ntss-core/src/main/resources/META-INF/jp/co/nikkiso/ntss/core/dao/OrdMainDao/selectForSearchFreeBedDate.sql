select
  treat_date
from
  ord_main
where
  facility_cd = /*facilityCd*/null
and
  pat_id = /*patId*/null
/*%if null != searchStartDate*/
and
  treat_date >= /*searchStartDate*/null
/*%end*/
/*%if null != searchEndDate*/
and
  treat_date <= /*searchEndDate*/null
/*%end*/
/*%if 0 != treatWeekList.size() && 0 != treatWeekList.get(0)*/
and
  treat_week in /*treatWeekList*/(null)
/*%end */
/*%if false == isAll*/
and
  treat_date not in(
    select
      main.treat_date
    from
      ord_main main inner join ord_schedule schedule on main.treat_date = schedule.treat_date
    where
      main.pat_id = /*patId*/null
    and
      schedule.facility_cd = /*facilityCd*/null
    /*%if null != searchStartDate*/
    and
      main.treat_date >= /*searchStartDate*/null
    /*%end*/
    /*%if null != searchEndDate*/
    and
      main.treat_date <= /*searchEndDate*/null
    /*%end*/
    /*%if null != kurCd*/
    and
      schedule.kur_cd = /*kurCd*/null
    /*%end */
    /*%if 0 != treatWeekList.size() && 0 != treatWeekList.get(0)*/
    and
      schedule.treat_week in /*treatWeekList*/(null)
    /*%end */
    /*%if null != bedCd*/
    and
      schedule.bed_cd  = /*bedCd*/null
    /*%end */
    group by main.treat_date
    order by main.treat_date
  )
/*%end */
order by treat_date
;