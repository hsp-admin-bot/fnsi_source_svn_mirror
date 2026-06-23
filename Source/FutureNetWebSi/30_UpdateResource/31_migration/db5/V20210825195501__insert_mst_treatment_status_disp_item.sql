INSERT INTO mst_treatment_status_disp_item (item_cd, data_class, machine_class, item_name, table_name, field_name, json_key_name, disp_order, is_disp, is_del, reg_date, up_date)
SELECT 112, '1', '0', '終了予測(補液完了)', null, null, null, 0, '1', '0', current_timestamp, current_timestamp
WHERE NOT EXISTS (SELECT item_cd FROM mst_treatment_status_disp_item WHERE item_cd = 112);
