WITH updates AS (
  SELECT facility_cd, pat_event_cd, treat_date, old_treat_date
  FROM (
     VALUES
       (null, 0, null, null)
       /*%for isl : indScheduleInfoList */
         /*%for islevntcd : isl.connectedPatEventCdList */
         ,(
           /*isl.facilityCd*/null,
           /*islevntcd*/0,
           /*isl.treatDate*/null,
           /*isl.oldTreatDate*/null
         )
         /*%end*/
      /*%end*/
   ) AS t(facility_cd, pat_event_cd, treat_date, old_treat_date) WHERE t.treat_date != t.old_treat_date
)
select pat_event.*
FROM pat_event, updates AS u
WHERE
  pat_event.facility_cd = /*facilityCd*/null AND
  pat_event.facility_cd = u.facility_cd AND
  pat_event.pat_event_cd = u.pat_event_cd AND
  pat_event.is_del = '0'
