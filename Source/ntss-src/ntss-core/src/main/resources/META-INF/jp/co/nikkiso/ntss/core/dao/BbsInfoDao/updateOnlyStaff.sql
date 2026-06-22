update bbs_info
set
--  bbs_ctl_no = /* bbs.pat_id */null,
--  facility_cd = /* bbs.facility_cd */null,
  staff_info = /* bbs.staff_info */null
--  upd_staff_id = /* bbs.upd_staff_id */null,
--  upd_staff_name = /* bbs.upd_staff_name */null,
--  up_date = to_timestamp(/* bbs.up_date */null, 'YYYY-MM-DD HH24:MI:SS')
where
  bbs_ctl_no = /*bbs.bbs_ctl_no*/null
  /*%if curLoginFacilityCd != null */
    and facility_cd = /*curLoginFacilityCd*/null
  /*%end */
;
