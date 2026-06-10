update sys_system_define
set
/*%if param.serviceCd != null */
    service_cd = /* param.serviceCd */'99',
/*%end*/
/*%if param.name != null */
    name = /* param.name */'1',
/*%end*/
/*%if param.value != null */
    value = /*param.value*/'{"0":"1"}'::JSONB,
/*%end*/
/*%if param.description != null */
    description = /* param.description */'1',
/*%end*/
/*%if param.isEnable != null */
    is_enable = /* param.isEnable */1,
/*%end*/
  up_date = CURRENT_TIMESTAMP
where
  facility_cd = /*param.facilityCd*/'999000' and
  ctl_no = /*param.ctlNo*/1
;