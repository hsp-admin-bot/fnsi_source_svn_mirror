UPDATE mst_pat_viewer_layout
SET disp_item_info = regexp_replace( disp_item_info::text, '"itemNo":\s*null,\s*"itemName":\s*"血流量"', '"itemNo":"1*2*8","itemName":"血流量"', 'g' )::jsonb
where layout_cd in (
    SELECT DISTINCT t2.layout_cd
    FROM mst_pat_viewer_layout t2,
    jsonb_array_elements(t2.disp_item_info) c,
    jsonb_array_elements(c->'categoryItem') ci,
    jsonb_array_elements(ci->'subCategoryItem') si
    WHERE (si->>'itemNo') IS NULL
  AND (si->>'itemName') is not null and (si->>'itemName') LIKE '%血流量%'
    )
