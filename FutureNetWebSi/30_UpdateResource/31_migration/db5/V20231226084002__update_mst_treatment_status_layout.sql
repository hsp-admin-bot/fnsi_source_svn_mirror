-- 治療状況レイアウトマスタのdcs_view_itemsから'担当1日時'～を削除する
UPDATE mst_treatment_status_layout
SET dcs_view_items = (
        SELECT jsonb_agg(elem)
        FROM (
            SELECT *
            FROM jsonb_array_elements(dcs_view_items) AS items(elem)
            WHERE NOT (items.elem->>'title' IN (
                '担当1日時', '担当2日時', '穿刺1日時', '穿刺2日時', '返血1日時', '返血2日時'
            ))
        ) AS filtered
    ),
    up_date = current_timestamp
WHERE
    dcs_view_items IS NOT NULL;