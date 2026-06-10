WITH updates AS (
  SELECT facility_cd, ord_no, treat_date, ind_kur_cd, ind_treat_start_time, ind_bed_cd
  FROM (
     VALUES
       (null, 0, null, 0, null, 0),
       /*%for isl : indScheduleInfoList */
       (
         /*isl.facilityCd*/null,
         /*isl.ordNo*/0,
         /*isl.treatDate*/null,
         /*isl.indKurCd*/0,
         /*isl.indTreatStartTime*/null,
         /*isl.indBedCd*/0
       )
       /*%if isl_has_next */
       /*# "," */
       /*%end*/
      /*%end*/
   ) AS t(facility_cd, ord_no, treat_date, ind_kur_cd, ind_treat_start_time, ind_bed_cd)
)
select  ord_schedule.*
FROM ord_schedule, updates AS u
WHERE
  ord_schedule.facility_cd = /*facilityCd*/null AND
  ord_schedule.facility_cd = u.facility_cd AND
  ord_schedule.ord_no = u.ord_no AND
  ord_schedule.is_dummy = '0'
