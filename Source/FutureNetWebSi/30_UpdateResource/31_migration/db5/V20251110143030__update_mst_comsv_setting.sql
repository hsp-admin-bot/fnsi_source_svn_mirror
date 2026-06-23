UPDATE mst_comsv_setting
SET is_disp = '0'
WHERE ( facility_cd, device_edge_no ) IN ( SELECT T.facility_cd, T.device_edge_no FROM mst_device_edge T WHERE T.is_del = '1' AND T.is_disp = '0' )
