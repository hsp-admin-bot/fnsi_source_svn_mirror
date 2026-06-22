select
  pat_id
from
  pat_main
where
   facility_cd = /*facilityCd*/'000001'
and pat_id in /*patIdList*/( NULL )
and
(
 CASE
    WHEN sch_ext_end_date IS NULL THEN
    to_char(
        date_trunc('month', CURRENT_DATE + interval '1 year') + interval '1 month - 1 day',
        'YYYYMMDD'
	)
    ELSE sch_ext_end_date
 END
) < /* targetTreatDate */null
order by
  facility_cd,
  pat_id
;
