select distinct
  /*%expand "A" */*
from
  bbs_info A,
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--   to_char(A.notice_fac_cal_start_date, 'YYYYMMDD') as start_date,
--   to_cahr(A.notice_fac_cal_end_date, 'YYYYMMDD') as end_date
  to_date(A.notice_fac_cal_start_date, 'YYYYMMDD') as start_date,
  to_date(A.notice_fac_cal_end_date, 'YYYYMMDD') as end_date
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end

where
  facility_cd = /* facility_cd */null
/*%if text != null */
  and (
    UPPER(A.content) like '%' || /*text*/'' || '%' or UPPER(A.title) like '%' || /*text*/'' || '%'
  )
/*%end */

--- 期間指定
/*%if notice_start_date != null && notice_end_date != null */
  and (
	  (/* notice_start_date */null <= start_date and  start_date <= /* notice_end_date */null)
	  or (/* notice_start_date */null <= end_date and end_date <= /* notice_end_date */null)
	  or (start_date <= /* notice_start_date */null and /* notice_end_date */null <= end_date)
	  or (start_date <= /* notice_end_date */null and end_date is null)
  )
/*%end */

--- オーダー番号
/*%if  (dialysis_date != null || kur_cd != null || room_bed_group_cd.size() != 0)　*/
  and bbs_ctl_no in /* bbsCtlNoList */(null)
/*%end*/

	and A.is_del = '0'
	and A.is_disp = '1'
	
/*%if !isDispBbsAll */
    and A.is_disp_bbs in ('2','3')
/*%end */

order by A.bbs_ctl_no asc
;
