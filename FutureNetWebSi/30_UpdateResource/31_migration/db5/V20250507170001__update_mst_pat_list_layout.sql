-- #10934 データリストの行背景色がオレンジ色のスタイル修正
-- 治療予定・治療記録から「治療日」を除去
UPDATE mst_pat_list_layout
SET disp_item_info = (
    SELECT jsonb_agg(elem)
    FROM jsonb_array_elements(disp_item_info) AS elem
    WHERE elem->>'data_list_detail_cd' <> '1404'
),
up_date=now()
WHERE template_cd = 5;
