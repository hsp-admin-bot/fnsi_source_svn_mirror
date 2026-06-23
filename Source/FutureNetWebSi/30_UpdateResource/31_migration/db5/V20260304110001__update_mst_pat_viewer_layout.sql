UPDATE mst_pat_viewer_layout 
SET disp_item_info = replace(disp_item_info::text, '{"rstCd": 14, "component": "rst-info", "subCategoryNo": 30, "subCategoryItem": [{"itemNo": 1, "itemName": "透析運転時間"}], "subCategoryName": "透析運転時間"}', '{"rstCd": 14, "component": "rst-info", "subCategoryNo": 30, "subCategoryItem": [{"itemNo": 1, "itemName": "治療時間(実績)"}], "subCategoryName": "治療時間(実績)"}')::jsonb
WHERE
	disp_item_info::text LIKE '%{"rstCd": 14, "component": "rst-info", "subCategoryNo": 30, "subCategoryItem": [{"itemNo": 1, "itemName": "透析運転時間"}], "subCategoryName": "透析運転時間"}%';

UPDATE mst_pat_viewer_layout 
SET disp_item_info = replace(disp_item_info::text, '{"rstCd": 14, "component": "rst-info", "subCategoryNo": 30, "subCategoryItem": [{"itemNo": 1, "itemName": "透析運転時間", "itemColor": "#000000", "itemPoint": "triangle"}], "subCategoryName": "透析運転時間"}', '{"rstCd": 14, "component": "rst-info", "subCategoryNo": 30, "subCategoryItem": [{"itemNo": 1, "itemName": "治療時間(実績)", "itemColor": "#000000", "itemPoint": "triangle"}], "subCategoryName": "治療時間(実績)"}')::jsonb
WHERE
	disp_item_info::text LIKE '%{"rstCd": 14, "component": "rst-info", "subCategoryNo": 30, "subCategoryItem": [{"itemNo": 1, "itemName": "透析運転時間", "itemColor": "#000000", "itemPoint": "triangle"}], "subCategoryName": "透析運転時間"}%';
