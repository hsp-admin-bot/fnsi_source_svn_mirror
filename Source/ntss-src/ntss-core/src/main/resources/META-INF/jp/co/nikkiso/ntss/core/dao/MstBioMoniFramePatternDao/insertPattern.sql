insert into mst_bio_moni_frame_pattern 
  (facility_cd, ctl_no, template_name, frame_type, frame_no, define_info, reg_date, up_date)
values
  (/*param.facilityCd*/'999000', 
  /*param.ctlNo*/1, 
  /*param.templateName*/'hoge', 
  /*param.frameType*/0, 
  /*param.frameNo*/1, 
  /*param.defineInfo*/'{"0":"1"}'::JSONB, 
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP)
;