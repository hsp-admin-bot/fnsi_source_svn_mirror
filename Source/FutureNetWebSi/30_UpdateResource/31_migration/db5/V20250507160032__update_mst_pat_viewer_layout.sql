UPDATE mst_pat_viewer_layout						
SET disp_item_info = (						
  SELECT jsonb_agg(						
    CASE						
      WHEN category ->> 'categoryNo' IS NOT NULL AND						
           ((category ->> 'categoryNo')::int BETWEEN 1024 AND 1027						
            OR (category ->> 'categoryNo')::int BETWEEN 1008 AND 1011						
	OR (category ->> 'categoryNo')::int BETWEEN 8 AND 11)					
      THEN jsonb_set(						
        category,						
        '{categoryItem}',						
        to_jsonb((						
          SELECT jsonb_agg(						
            CASE						
              WHEN jsonb_typeof(ci) = 'object' THEN						
            jsonb_set(						
              ci,						
              '{subCategoryItem}',						
              coalesce(						
                to_jsonb((						
                  SELECT jsonb_agg(						
                    CASE						
                      WHEN (category ->> 'categoryNo')::int BETWEEN 1024 AND 1027 AND						
                           item ->> 'itemDivision' = '2' AND						
                           item ->> 'itemNo' NOT IN ('prediction', 'regression_line')	AND					
	 item ->> 'itemExamClass' IS NULL					
                        THEN item || jsonb_build_object('itemExamClass', 3)						
						
                      WHEN (category ->> 'categoryNo')::int BETWEEN 1008 AND 1011 AND						
                           item ->> 'itemNo' NOT IN ('prediction', 'regression_line')	AND					
	 item ->> 'itemExamClass' IS NULL					
                        THEN item || jsonb_build_object('itemExamClass', 3)						
	WHEN (category ->> 'categoryNo')::int BETWEEN 8 AND 11 AND					
			 item ->> 'itemExamClass' IS NULL			
						
                        THEN item || jsonb_build_object('itemExamClass', 3)						
						
                      ELSE item						
                    END						
                  )						
                  FROM jsonb_array_elements(ci -> 'subCategoryItem') AS item						
                )),						
                '[]'::jsonb						
              )						
            )						
              ELSE ci						
            END						
          )						
          FROM jsonb_array_elements(category -> 'categoryItem') AS ci						
        ))						
      )						
      ELSE category						
    END						
  )						
  FROM jsonb_array_elements(disp_item_info) AS category						
)						
WHERE disp_item_info IS NOT NULL AND disp_item_info <> '[]'::jsonb;						
