UPDATE pat_treatment_pattern	
SET ind_cond_info =	
    jsonb_set(	
        ind_cond_info,	
        '{19,medicine_type}',	
        CASE	
            WHEN (ind_cond_info->'19'->>'value') IS NOT NULL	
                THEN '"1"'::jsonb	
            ELSE 'null'::jsonb	
        END,	
        true	
    )	
WHERE	
    ind_cond_info IS NOT NULL	
    AND ind_cond_info ? '19'	
    AND NOT (ind_cond_info->'19' ? 'medicine_type');