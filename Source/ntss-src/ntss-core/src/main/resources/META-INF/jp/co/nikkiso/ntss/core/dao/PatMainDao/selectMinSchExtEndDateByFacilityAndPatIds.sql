SELECT
  min(sch_ext_end_date)
FROM
  pat_main
WHERE
  facility_cd = /*facility_cd*/null
  and pat_id in /* patIdList */(0)
  and is_del = '0'
;
