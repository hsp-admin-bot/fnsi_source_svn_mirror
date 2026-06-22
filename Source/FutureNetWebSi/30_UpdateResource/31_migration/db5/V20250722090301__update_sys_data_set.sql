DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1106009);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106009, 'SELECT
    1
FROM 
    pat_rad_main prm
CROSS JOIN LATERAL json_array_elements(prm.order_rad_set_info::json) info
JOIN mst_rad_set mrs ON
    (info ->> ''rad_set_cd'')::integer = mrs.rad_set_cd
CROSS JOIN LATERAL json_array_elements(mrs.rad_item_info::json) item_info
WHERE
    prm.rad_result_cd = @ordNo
    AND prm.facility_cd = @facilityCd
    AND prm.pat_id = @patId
    AND prm.is_del = ''0''
    AND COALESCE(item_info ->> ''item_cd'', '''') <> ''''
    AND item_info ->> ''item_class'' = ''部位''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_放射線オーダー連携 is_zero_end', '2025-07-18 20:19:41.142', CURRENT_TIMESTAMP, NULL);