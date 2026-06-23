UPDATE mst_pat_viewer_layout l
SET disp_item_info = (
  SELECT jsonb_agg(
           jsonb_set(
             cat_obj,
             '{categoryItem}',
             COALESCE(
               (
                 SELECT jsonb_agg(item_obj ORDER BY item_ord)
                 FROM jsonb_array_elements(cat_obj->'categoryItem') WITH ORDINALITY AS i(item_obj, item_ord)
                 WHERE NOT (
                   jsonb_typeof(item_obj->'subCategoryItem') = 'array'
                   AND jsonb_array_length(item_obj->'subCategoryItem') = 0
                 )
               ),
               '[]'::jsonb
             )
           )
           ORDER BY cat_ord
         )
  FROM jsonb_array_elements(l.disp_item_info) WITH ORDINALITY AS c(cat_obj, cat_ord)
)
WHERE EXISTS (
  SELECT 1
  FROM jsonb_array_elements(l.disp_item_info) AS c(cat_obj),
       jsonb_array_elements(cat_obj->'categoryItem') AS i(item_obj)
  WHERE jsonb_typeof(item_obj->'subCategoryItem') = 'array'
    AND jsonb_array_length(item_obj->'subCategoryItem') = 0
);