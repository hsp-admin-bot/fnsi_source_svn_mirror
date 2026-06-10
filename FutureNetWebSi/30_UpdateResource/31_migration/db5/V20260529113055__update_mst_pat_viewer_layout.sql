UPDATE mst_pat_viewer_layout t
SET disp_item_info = (
    SELECT jsonb_agg(
                       category || jsonb_build_object(
                           'categoryItem',
                           (
                               SELECT COALESCE(
                                              jsonb_agg(categoryItem),
                                              '[]'::jsonb
                                          )
                               FROM jsonb_array_elements(category->'categoryItem') categoryItem
                               WHERE NOT EXISTS (
                                       SELECT 1
                                       FROM jsonb_array_elements(categoryItem->'subCategoryItem') subItem
                                       WHERE (subItem->>'itemNo') IS NULL
                                         AND (subItem->>'itemName') IS NULL
                                   )
                           )
                       )
               )
    FROM jsonb_array_elements(t.disp_item_info) category
)
WHERE t.layout_cd IN (
    SELECT DISTINCT t2.layout_cd
    FROM mst_pat_viewer_layout t2,
         jsonb_array_elements(t2.disp_item_info) c,
         jsonb_array_elements(c->'categoryItem') ci,
         jsonb_array_elements(ci->'subCategoryItem') si
    WHERE (si->>'itemNo') IS NULL
      AND (si->>'itemName') IS NULL
);
