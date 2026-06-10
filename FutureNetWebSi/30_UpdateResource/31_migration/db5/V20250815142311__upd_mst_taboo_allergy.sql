UPDATE mst_taboo_allergy
SET detail_info = '[]'::jsonb
WHERE detail_info IS NULL;
