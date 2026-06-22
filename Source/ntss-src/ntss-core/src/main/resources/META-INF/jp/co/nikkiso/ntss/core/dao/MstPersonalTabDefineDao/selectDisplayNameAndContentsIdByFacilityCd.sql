SELECT
  tab_define_cd
  , display_name
  , contents_id
  , mode
FROM
  mst_personal_tab_define
WHERE
  (facility_cd like /* "%" + facilityCd + "%" */'%000000%' OR facility_cd IS NULL)
AND
  is_disp = '1'
AND
  is_del = '0'
ORDER BY
  disp_order
;
