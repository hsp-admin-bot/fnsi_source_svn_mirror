UPDATE mst_pat_viewer_layout
SET disp_item_info = regexp_replace(
    disp_item_info::text,
    '"itemNo":\s*null,\s*"itemName":\s*"ダイアライザ"',
    '"itemNo":"dializer","itemName":"ダイアライザ"',
    'g'
)::jsonb
WHERE layout_cd IN (
    SELECT DISTINCT t2.layout_cd
    FROM mst_pat_viewer_layout t2,
         jsonb_array_elements(t2.disp_item_info) c,
         jsonb_array_elements(c->'categoryItem') ci,
         jsonb_array_elements(ci->'subCategoryItem') si
    WHERE (si->>'itemNo') IS NULL
      AND (si->>'itemName') = 'ダイアライザ'
);

UPDATE mst_pat_viewer_layout
SET disp_item_info = regexp_replace(
    disp_item_info::text,
    '"itemNo":\s*null,\s*"itemName":\s*"治療時間"',
    '"itemNo":"treatment_time","itemName":"治療時間"',
    'g'
)::jsonb
WHERE layout_cd IN (
    SELECT DISTINCT t2.layout_cd
    FROM mst_pat_viewer_layout t2,
         jsonb_array_elements(t2.disp_item_info) c,
         jsonb_array_elements(c->'categoryItem') ci,
         jsonb_array_elements(ci->'subCategoryItem') si
    WHERE (si->>'itemNo') IS NULL
      AND (si->>'itemName') = '治療時間'
);