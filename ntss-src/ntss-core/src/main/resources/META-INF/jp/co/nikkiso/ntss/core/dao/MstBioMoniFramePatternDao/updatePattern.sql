update mst_bio_moni_frame_pattern
set
/*%if param.templateName != null */
    template_name = /* param.templateName */'99',
/*%end*/
/*%if param.frameType != null */
    frame_type = /* param.frameType */1,
/*%end*/
/*%if param.frameNo != null */
    frame_no = /* param.frameNo */1,
/*%end*/
/*%if param.defineInfo != null */
    define_info = /*param.defineInfo*/'{"0":"1"}'::JSONB,
/*%end*/
  up_date = CURRENT_TIMESTAMP
where
  facility_cd = /*param.facilityCd*/'999000' and
  ctl_no = /*param.ctlNo*/1
;