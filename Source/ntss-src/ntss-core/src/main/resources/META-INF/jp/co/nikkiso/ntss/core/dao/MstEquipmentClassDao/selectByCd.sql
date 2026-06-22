SELECT
  A.class_cd
  , A.facility_cd
  , A.fn_class_cd
  , A.class_name
  , A.class_type
  , A.in_hospital_cd_1
  , A.is_disp
  , A.is_del
  , A.is_editable
  , A.reg_date
  , A.up_date
FROM
  mst_equipment_class A
WHERE
  class_cd = /* classCd */'0'
AND
  is_del = '0'
;
