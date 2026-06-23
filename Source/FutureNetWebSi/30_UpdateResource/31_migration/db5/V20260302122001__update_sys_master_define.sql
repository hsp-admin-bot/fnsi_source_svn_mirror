-- #12091 検査依頼　新規画面対応
-- 「V20251028112102__update_sys_master_define」で追加したSQLの不具合対応
-- 検査区分が複数登録されてしまう
UPDATE ntss.sys_master_define
SET column_info = jsonb_set(
    column_info,
    '{fields}',
    (
        SELECT jsonb_agg(elem)
        FROM (
            SELECT elem
            FROM jsonb_array_elements(column_info->'fields') WITH ORDINALITY AS t(elem, ord)
            WHERE NOT (
                elem->>'physical_name' = 'order_class'
                AND ord > (
                    SELECT MIN(ord2)
                    FROM jsonb_array_elements(column_info->'fields') WITH ORDINALITY AS t2(elem2, ord2)
                    WHERE elem2->>'physical_name' = 'order_class'
                )
            )
            ORDER BY ord
        ) AS cleaned
    )
)
WHERE master_physical_name = 'mst_exam_set';
