UPDATE mst_pat_search_detail					
SET search_condition = 					
    CASE 					
        WHEN (search_condition ->> 'dialysisStartDate' = '' AND search_condition ->> 'dialysisEndDate' = '') 					
        THEN jsonb_set(to_jsonb(search_condition), '{dialysisDateArgs}', '""', true)					
					
        WHEN (search_condition ->> 'dialysisDateArgs' IS NULL OR search_condition ->> 'dialysisDateArgs' = '') 					
             AND (search_condition ->> 'dialysisStartDate' <> '' OR search_condition ->> 'dialysisEndDate' <> '') 					
        THEN jsonb_set(to_jsonb(search_condition), '{dialysisDateArgs}', '"specifiedPeriod"', true)					
					
        ELSE to_jsonb(search_condition)					
    END					
WHERE 					
    (search_condition ->> 'dialysisStartDate' <> '' OR search_condition ->> 'dialysisEndDate' <> '')					
    OR (search_condition ->> 'dialysisStartDate' = '' AND search_condition ->> 'dialysisEndDate' = '')					
