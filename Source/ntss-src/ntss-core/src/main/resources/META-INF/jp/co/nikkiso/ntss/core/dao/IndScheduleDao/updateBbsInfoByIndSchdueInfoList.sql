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
UPDATE bbs_info
SET
  notice_start_date = CASE WHEN notice_start_date IS NOT NULL THEN TO_CHAR(TO_DATE(bbs_info.notice_start_date, 'YYYYMMDD') + u.date_diff * INTERVAL '1 day', 'YYYYMMDD') ELSE bbs_info.notice_start_date END,
  notice_end_date = CASE WHEN notice_start_date IS NOT NULL AND notice_end_date IS NOT NULL THEN TO_CHAR(TO_DATE(bbs_info.notice_end_date, 'YYYYMMDD') + u.date_diff * INTERVAL '1 day', 'YYYYMMDD') ELSE bbs_info.notice_end_date END,
  notice_fac_cal_start_date = CASE WHEN notice_start_date IS NOT NULL AND notice_start_date IS NOT NULL THEN TO_CHAR(TO_DATE(bbs_info.notice_fac_cal_start_date, 'YYYYMMDD') + u.date_diff * INTERVAL '1 day', 'YYYYMMDD') ELSE bbs_info.notice_fac_cal_start_date END,
  notice_fac_cal_end_date = CASE WHEN notice_start_date IS NOT NULL AND notice_start_date IS NOT NULL AND notice_end_date IS NOT NULL THEN TO_CHAR(TO_DATE(bbs_info.notice_fac_cal_end_date, 'YYYYMMDD') + u.date_diff * INTERVAL '1 day', 'YYYYMMDD') ELSE bbs_info.notice_fac_cal_end_date END,
  up_date = CASE WHEN notice_start_date IS NOT NULL THEN transaction_timestamp() ELSE bbs_info.up_date END
FROM updates AS u
WHERE
  bbs_info.facility_cd = /*facilityCd*/null AND
  bbs_info.facility_cd = u.facility_cd AND
  bbs_info.bbs_ctl_no = u.bbs_ctl_no AND
  bbs_info.is_del = '0' AND
  bbs_info.is_disp = '1'
RETURNING bbs_info.*
