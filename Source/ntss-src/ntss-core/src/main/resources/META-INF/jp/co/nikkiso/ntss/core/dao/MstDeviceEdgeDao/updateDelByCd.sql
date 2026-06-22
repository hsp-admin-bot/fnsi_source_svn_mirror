update mst_device_edge
set
  is_disp = '0',
  is_del = '1',
  up_date = CURRENT_TIMESTAMP
where
  serial_no = /* serialNo */null
;
