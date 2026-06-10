SELECT
  insurance_cd,
  case
    when insu_class = /*insuClass*/NULL then (insu_self_info::json->>'insu_self_name')::text
    else insu_name
  end insu_name,  
  is_selected,
  is_del
FROM
  pat_insurance
WHERE 
    pat_id = /*patId*/NULL
  And facility_cd = /*facilityCd*/NULL
  And is_del = '0'
  And is_disp = '1'
ORDER BY
  is_selected DESC, ctl_no ASC
  ;