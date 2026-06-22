WITH updates AS (
  SELECT facility_cd, bbs_ctl_no, treat_date, old_treat_date
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
   ) AS t(facility_cd, bbs_ctl_no, treat_date, old_treat_date) WHERE t.treat_date != t.old_treat_date
)
UPDATE bbs_info
SET
  is_del = '1',
  is_disp = '0',
  up_date = transaction_timestamp()
FROM updates AS u
WHERE
  bbs_info.facility_cd = /*facilityCd*/null AND
  bbs_info.facility_cd = u.facility_cd AND
  bbs_info.bbs_ctl_no = u.bbs_ctl_no AND
  bbs_info.is_del = '0' AND
  bbs_info.is_disp = '1'
RETURNING bbs_info.*
