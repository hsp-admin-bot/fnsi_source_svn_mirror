update bbs_info
set
--  bbs_ctl_no = /* bbs.pat_id */null,
--  facility_cd = /* bbs.facility_cd */null,
  file_info =  file_info::jsonb || /* file_info */null::jsonb
where
  bbs_ctl_no = /*bbs_ctl_no*/null
  and  not file_info::jsonb @> /* file_info */null::jsonb
;