WITH updates AS (
  SELECT facility_cd, bbs_ctl_no, treat_date, oldTreatDate, TO_DATE(treat_date, 'YYYYMMDD') - TO_DATE(oldTreatDate, 'YYYYMMDD') AS date_diff
  FROM (
     VALUES
       (null, 0, null, null)
       /*%for isl : indScheduleInfoList */
         /*%for islctlno : isl.connectedBbsCtlNoList */
         ,(
           /*isl.facilityCd*/null,
           /*islctlno*/0,
           /*isl.treatDate*/null,
           /*isl.oldTreatDate*/null
         )
         /*%end*/
      /*%end*/
   ) AS t(facility_cd, bbs_ctl_no, treat_date, oldTreatDate) WHERE t.treat_date != t.oldTreatDate
)
select bbs_info.*
FROM bbs_info, updates AS u
WHERE
  bbs_info.facility_cd = /*facilityCd*/null AND
  bbs_info.facility_cd = u.facility_cd AND
  bbs_info.bbs_ctl_no = u.bbs_ctl_no AND
  bbs_info.is_del = '0' AND
  bbs_info.is_disp = '1'
