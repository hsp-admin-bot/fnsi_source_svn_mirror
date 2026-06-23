UPDATE ntss.mst_weight
SET check_content = new_content,
    up_date = CASE WHEN new_content IS DISTINCT FROM check_content THEN now() ELSE up_date END
FROM (
    SELECT weight_cd,
           jsonb_agg(
               jsonb_set(
                   jsonb_set(
                       jsonb_set(elem, '{calculate}', to_jsonb(COALESCE(elem->>'calculate', '')), true),
                       '{after_word}', to_jsonb(COALESCE(elem->>'after_word', '')), true
                   ),
                   '{before_word}', to_jsonb(COALESCE(elem->>'before_word', '')), true
               )
           ) AS new_content
    FROM ntss.mst_weight,
         jsonb_array_elements(check_content) AS elem
    WHERE check_content IS NOT NULL
    GROUP BY weight_cd
) sub
WHERE ntss.mst_weight.weight_cd = sub.weight_cd;
