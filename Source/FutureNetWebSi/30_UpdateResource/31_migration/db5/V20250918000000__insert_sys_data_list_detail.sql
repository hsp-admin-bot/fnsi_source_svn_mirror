-- #11124 酸素飽和度対応
-- データリスト（ΔSO2低下報知点）追加
DELETE from ntss.sys_data_list_detail where data_list_detail_cd = 1449;

INSERT INTO ntss.sys_data_list_detail
  (data_list_detail_cd, disp_order, category_cd, master_display_name, master_display_type, master_display_sql, function_display_name, function_display_type, function_display_sql, data_set, cell_display)
  VALUES(1449, 7, 119, 'ΔSO2低下報知点', 2, NULL, 'ΔSO2低下報知点', 2, NULL, NULL, NULL);
