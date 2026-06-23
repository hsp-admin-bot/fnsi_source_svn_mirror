UPDATE ord_main	
SET rst_cond_info =	
    jsonb_set(	
        rst_cond_info,	
        '{19,medicine_type}',	
        CASE	
            WHEN (rst_cond_info->'19'->>'value') IS NOT NULL	
                THEN '"1"'::jsonb	
            ELSE 'null'::jsonb	
        END,	
        true	
    )	
WHERE	
    rst_cond_info IS NOT NULL	
    AND rst_cond_info ? '19'	
    AND NOT (rst_cond_info->'19' ? 'medicine_type');