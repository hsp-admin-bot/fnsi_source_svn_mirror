-- 水質検査種別マスタ 更新
UPDATE sys_master_define
SET column_info = 
    jsonb_set(
        column_info, 
        '{fields}',
        (
            SELECT jsonb_agg(
                CASE 
                    WHEN elem->>'title' = '水質検査種別名' 
                    THEN elem || '{"locked": "true"}'::jsonb
                    ELSE elem
                END
            )
            FROM jsonb_array_elements(column_info->'fields') AS elem
        )
    ),
    up_date = CURRENT_TIMESTAMP 
WHERE master_physical_name = 'mst_water_survey_type';

-- 水質検査箇所マスタ 更新
UPDATE sys_master_define
SET column_info = 
    jsonb_set(
        column_info, 
        '{fields}',
        (
            SELECT jsonb_agg(
                CASE 
                    WHEN elem->>'title' = '水質検査箇所名' 
                    THEN elem || '{"locked": "true"}'::jsonb
                    ELSE elem
                END
            )
            FROM jsonb_array_elements(column_info->'fields') AS elem
        )
    ),
    up_date = CURRENT_TIMESTAMP 
WHERE master_physical_name = 'mst_water_survey_point';
