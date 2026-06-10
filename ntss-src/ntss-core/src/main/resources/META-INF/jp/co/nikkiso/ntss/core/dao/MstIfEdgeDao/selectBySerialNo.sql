SELECT
    A.serial_no, 
    A.facility_cd, 
    A.if_edge_no, 
    A.if_edge_name, 
    A.is_disp, 
    A.is_del, 
    A.setting_date, 
    A.delete_date, 
    A.memo, 
    A.reg_date, 
    A.up_date
FROM
  mst_if_edge A
WHERE
  A.serial_no = /* serialNo */'999999'