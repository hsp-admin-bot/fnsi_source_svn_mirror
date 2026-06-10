UPDATE mst_pat_viewer_layout 
SET disp_item_info = regexp_replace(disp_item_info::text, 'reduction_rate', 'weight_after')::jsonb
WHERE
	mst_pat_viewer_layout.layout_cd IN (
	SELECT
		cd itemNo 
	FROM
		(
		SELECT ELEMENT
			->> 'subCategoryItem' AS categoryItem , cd
		FROM
			( SELECT VALUE ->> 'categoryItem' AS item,mpvl.layout_cd as cd	FROM mst_pat_viewer_layout mpvl, jsonb_array_elements ( mpvl.disp_item_info ) AS tem WHERE tem ->> 'component' = 'weight' ) v,
			jsonb_array_elements ( v.item :: jsonb ) AS ELEMENT 
		) C,
		jsonb_array_elements ( C.categoryItem :: jsonb ) AS category 
	WHERE
		category ->> 'itemName' = '透析後体重' 
	AND category ->> 'itemNo' = 'reduction_rate' 
	);
UPDATE mst_pat_viewer_layout
SET disp_item_info = regexp_replace(disp_item_info::text, 'reduction', 'weight_after')::jsonb
WHERE
	mst_pat_viewer_layout.layout_cd IN (
	SELECT
		cd itemNo 
	FROM
		(
		SELECT ELEMENT
			->> 'subCategoryItem' AS categoryItem , cd
		FROM
			( SELECT VALUE ->> 'categoryItem' AS item,mpvl.layout_cd as cd	FROM mst_pat_viewer_layout mpvl, jsonb_array_elements ( mpvl.disp_item_info ) AS tem WHERE tem ->> 'component' = 'weight' ) v,
			jsonb_array_elements ( v.item :: jsonb ) AS ELEMENT 
		) C,
		jsonb_array_elements ( C.categoryItem :: jsonb ) AS category 
	WHERE
		category ->> 'itemName' = '透析後体重' 
	AND category ->> 'itemNo' = 'reduction' 
	)