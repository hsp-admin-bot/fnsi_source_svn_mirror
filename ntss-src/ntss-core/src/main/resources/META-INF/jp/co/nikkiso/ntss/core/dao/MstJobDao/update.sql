update mst_job
set
  facility_cd = /* mstJob.facilityCd */null,
  job_name = /* mstJob.jobName */null,
  is_doctor = /* mstJob.isDoctor */null,
  default_menu_settings = /* mstJob.defaultMenuSettings */null,
  is_disp = /* mstJob.isDisp */null,
  is_del = /* mstJob.isDel */null,
  up_date = /*mstJob.upDate*/null,
  default_authorized_authorities = /*mstJob.defaultAuthorizedAuthorities*/null
where
  job_cd = /* mstJob.jobCd */null
;