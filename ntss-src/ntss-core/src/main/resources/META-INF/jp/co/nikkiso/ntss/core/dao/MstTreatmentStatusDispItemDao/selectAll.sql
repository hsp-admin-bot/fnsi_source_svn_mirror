SELECT
  A.item_cd
  , A.data_class
  , A.machine_class
  , A.item_name
  , A.table_name
  , A.field_name
  , A.json_key_name
  , A.disp_order
  , A.is_disp
  , A.is_del
  , A.reg_date
  , A.up_date
FROM
  mst_treatment_status_disp_item A
ORDER BY
  A.disp_order
  , A.item_cd
;
