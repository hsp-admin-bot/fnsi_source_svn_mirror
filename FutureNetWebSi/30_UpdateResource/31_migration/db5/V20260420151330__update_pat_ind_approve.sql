--check_content
UPDATE pat_ind_approve
SET check_content = (
  SELECT jsonb_agg(
   CASE
	 WHEN jsonb_typeof(cat->'subCategoryItem') = 'array'
	 THEN jsonb_set(
			cat,
			'{subCategoryItem}',
			(
			  SELECT COALESCE(
					   jsonb_agg(
						 CASE
						   WHEN (cat->>'subCategoryNo')::int = 4 AND (item->'itemInfo'->>'itemNo')::int NOT IN (17,22,26,27,28) THEN item
						   WHEN NOT (item->'itemInfo'->'data'->'value'->>'dispVal' ~ '^[0-9]+\.[0-9]{9,}$') THEN item
						   WHEN item->'itemInfo'->'data'->'value'->>'dispVal' IS NULL THEN item
						   ELSE jsonb_set(
								  item,
								  '{itemInfo,data,value,dispVal}',
								  to_jsonb(
									TO_CHAR(ROUND((item->'itemInfo'->'data'->'value'->>'dispVal')::numeric, 8), 'FM99999999990.00000000')
								  ),
								  false
								)
						 END
					   ),
					   cat->'subCategoryItem'
					 )
			  FROM jsonb_array_elements(cat->'subCategoryItem') AS item
			),
			false
		  )
	 ELSE cat
   END
  )
  FROM jsonb_array_elements(check_content) AS cat
)
WHERE check_content IS NOT NULL AND check_content != '{}'
  AND EXISTS (
    SELECT 1
    FROM jsonb_array_elements(check_content) cat,
         jsonb_array_elements(
           CASE WHEN jsonb_typeof(cat->'subCategoryItem')='array'
                THEN cat->'subCategoryItem'
                ELSE '[]'::jsonb
           END
         ) item
    WHERE
        (
          (cat->>'subCategoryNo')::int = 4 AND (item->'itemInfo'->>'itemNo')::int IN (17,22,26,27,28)
          AND item->'itemInfo'->'data'->'value'->>'dispVal' ~ '^[0-9]+\.[0-9]{9,}$'
        )
        OR ((cat->>'subCategoryNo')::int = 5 AND item->'itemInfo'->'data'->'value'->>'dispVal' ~ '^[0-9]+\.[0-9]{9,}$')
  );
--approve_content
UPDATE pat_ind_approve
SET approve_content = (
  SELECT jsonb_agg(
   CASE
	 WHEN jsonb_typeof(cat->'subCategoryItem') = 'array'
	 THEN jsonb_set(
			cat,
			'{subCategoryItem}',
			(
			  SELECT COALESCE(
					   jsonb_agg(
						 CASE
						   WHEN (cat->>'subCategoryNo')::int = 4 AND (item->'itemInfo'->>'itemNo')::int NOT IN (17,22,26,27,28) THEN item
						   WHEN NOT (item->'itemInfo'->'data'->'value'->>'dispVal' ~ '^[0-9]+\.[0-9]{9,}$') THEN item
						   WHEN item->'itemInfo'->'data'->'value'->>'dispVal' IS NULL THEN item
						   ELSE jsonb_set(
								  item,
								  '{itemInfo,data,value,dispVal}',
								  to_jsonb(
									TO_CHAR(ROUND((item->'itemInfo'->'data'->'value'->>'dispVal')::numeric, 8), 'FM99999999990.00000000')
								  ),
								  false
								)
						 END
					   ),
					   cat->'subCategoryItem'
					 )
			  FROM jsonb_array_elements(cat->'subCategoryItem') AS item
			),
			false
		  )
	 ELSE cat
   END
  )
  FROM jsonb_array_elements(approve_content) AS cat
)
WHERE approve_content IS NOT NULL AND approve_content != '{}'
  AND EXISTS (
    SELECT 1
    FROM jsonb_array_elements(approve_content) cat,
         jsonb_array_elements(
           CASE WHEN jsonb_typeof(cat->'subCategoryItem')='array'
                THEN cat->'subCategoryItem'
                ELSE '[]'::jsonb
           END
         ) item
    WHERE
        (
          (cat->>'subCategoryNo')::int = 4 AND (item->'itemInfo'->>'itemNo')::int IN (17,22,26,27,28)
          AND item->'itemInfo'->'data'->'value'->>'dispVal' ~ '^[0-9]+\.[0-9]{9,}$'
        )
        OR ((cat->>'subCategoryNo')::int = 5 AND item->'itemInfo'->'data'->'value'->>'dispVal' ~ '^[0-9]+\.[0-9]{9,}$')
  );
--content_for_map
UPDATE pat_ind_approve
SET content_for_map = (
  SELECT jsonb_agg(
   CASE
	 WHEN jsonb_typeof(cat->'subCategoryItem') = 'array'
	 THEN jsonb_set(
			cat,
			'{subCategoryItem}',
			(
			  SELECT COALESCE(
					   jsonb_agg(
						 CASE
						   WHEN (cat->>'subCategoryNo')::int = 4 AND (item->'itemInfo'->>'itemNo')::int NOT IN (17,22,26,27,28) THEN item
						   WHEN NOT (item->'itemInfo'->'data'->'value'->>'dispVal' ~ '^[0-9]+\.[0-9]{9,}$') THEN item
						   WHEN item->'itemInfo'->'data'->'value'->>'dispVal' IS NULL THEN item
						   ELSE jsonb_set(
								  item,
								  '{itemInfo,data,value,dispVal}',
								  to_jsonb(
									TO_CHAR(ROUND((item->'itemInfo'->'data'->'value'->>'dispVal')::numeric, 8), 'FM99999999990.00000000')
								  ),
								  false
								)
						 END
					   ),
					   cat->'subCategoryItem'
					 )
			  FROM jsonb_array_elements(cat->'subCategoryItem') AS item
			),
			false
		  )
	 ELSE cat
   END
  )
  FROM jsonb_array_elements(content_for_map) AS cat
)
WHERE content_for_map IS NOT NULL AND content_for_map != '{}'
  AND EXISTS (
    SELECT 1
    FROM jsonb_array_elements(content_for_map) cat,
         jsonb_array_elements(
           CASE WHEN jsonb_typeof(cat->'subCategoryItem')='array'
                THEN cat->'subCategoryItem'
                ELSE '[]'::jsonb
           END
         ) item
    WHERE
        (
          (cat->>'subCategoryNo')::int = 4 AND (item->'itemInfo'->>'itemNo')::int IN (17,22,26,27,28)
          AND item->'itemInfo'->'data'->'value'->>'dispVal' ~ '^[0-9]+\.[0-9]{9,}$'
        )
        OR ((cat->>'subCategoryNo')::int = 5 AND item->'itemInfo'->'data'->'value'->>'dispVal' ~ '^[0-9]+\.[0-9]{9,}$')
  );
