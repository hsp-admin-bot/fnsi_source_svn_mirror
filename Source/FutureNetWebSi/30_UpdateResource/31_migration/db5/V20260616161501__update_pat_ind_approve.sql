-- #12478 自動ワンショット(使用する/使用しない)→IPワンショットスタート(自動/手動)修正
-- 以下文言修正に伴い、指示受け承認情報(pat_ind_approve)テーブルの3つのカラムに対し、データ修正を行う。
-- 修正内容：
--     自動ワンショット→IPワンショットスタート
--     使用する→自動
--     使用しない→手動
-- 修正対象："subCategoryNo"が4 かつ "itemNo"が34


-- 治療単位指示受け時指示内容(check_content)カラム
UPDATE ntss.pat_ind_approve
SET
    check_content = (
        SELECT
            jsonb_agg(
                CASE
                    WHEN cat.elem ->> 'subCategoryNo' = '4'
                     AND jsonb_typeof(cat.elem -> 'subCategoryItem') = 'array'
                        THEN jsonb_set(
                            cat.elem,
                            '{subCategoryItem}',
                            (
                                SELECT
                                    jsonb_agg(
                                        CASE
                                            WHEN item.elem -> 'itemInfo' ->> 'itemNo' = '34'
                                                THEN (
                                                    SELECT
                                                        CASE
                                                            WHEN item_after_name -> 'itemInfo' -> 'data' -> 'value' ->> 'dispVal' = '使用する'
                                                                THEN jsonb_set(
                                                                    item_after_name,
                                                                    '{itemInfo,data,value,dispVal}',
                                                                    '"自動"'::jsonb,
                                                                    false
                                                                )
                                                            WHEN item_after_name -> 'itemInfo' -> 'data' -> 'value' ->> 'dispVal' = '使用しない'
                                                                THEN jsonb_set(
                                                                    item_after_name,
                                                                    '{itemInfo,data,value,dispVal}',
                                                                    '"手動"'::jsonb,
                                                                    false
                                                                )
                                                            ELSE item_after_name
                                                        END
                                                    FROM
                                                        (
                                                            SELECT
                                                                CASE
                                                                    WHEN item.elem -> 'itemInfo' ->> 'itemName' = '自動ワンショット'
                                                                        THEN jsonb_set(
                                                                            item.elem,
                                                                            '{itemInfo,itemName}',
                                                                            '"IPワンショットスタート"'::jsonb,
                                                                            false
                                                                        )
                                                                    ELSE item.elem
                                                                END AS item_after_name
                                                        ) AS tmp
                                                )
                                            ELSE item.elem
                                        END
                                        ORDER BY item.ord
                                    )
                                FROM
                                    jsonb_array_elements(cat.elem -> 'subCategoryItem')
                                        WITH ORDINALITY AS item(elem, ord)
                            ),
                            false
                        )
                    ELSE cat.elem
                END
                ORDER BY cat.ord
            )
        FROM
            jsonb_array_elements(check_content)
                WITH ORDINALITY AS cat(elem, ord)
    )
WHERE
    check_content IS NOT NULL
    AND jsonb_typeof(check_content) = 'array'
    AND EXISTS (
        SELECT
            1
        FROM
            jsonb_array_elements(check_content) AS cat(elem),
            jsonb_array_elements(
                CASE
                    WHEN jsonb_typeof(cat.elem -> 'subCategoryItem') = 'array'
                        THEN cat.elem -> 'subCategoryItem'
                    ELSE '[]'::jsonb
                END
            ) AS item(elem)
        WHERE
            cat.elem ->> 'subCategoryNo' = '4'
            AND item.elem -> 'itemInfo' ->> 'itemNo' = '34'
            AND (
                item.elem -> 'itemInfo' ->> 'itemName' = '自動ワンショット'
                OR item.elem -> 'itemInfo' -> 'data' -> 'value' ->> 'dispVal'
                    IN ('使用する', '使用しない')
            )
    );


-- 治療単位指示承認時指示内容(approve_content)カラム
UPDATE ntss.pat_ind_approve
SET
    approve_content = (
        SELECT
            jsonb_agg(
                CASE
                    WHEN cat.elem ->> 'subCategoryNo' = '4'
                     AND jsonb_typeof(cat.elem -> 'subCategoryItem') = 'array'
                        THEN jsonb_set(
                            cat.elem,
                            '{subCategoryItem}',
                            (
                                SELECT
                                    jsonb_agg(
                                        CASE
                                            WHEN item.elem -> 'itemInfo' ->> 'itemNo' = '34'
                                                THEN (
                                                    SELECT
                                                        CASE
                                                            WHEN item_after_name -> 'itemInfo' -> 'data' -> 'value' ->> 'dispVal' = '使用する'
                                                                THEN jsonb_set(
                                                                    item_after_name,
                                                                    '{itemInfo,data,value,dispVal}',
                                                                    '"自動"'::jsonb,
                                                                    false
                                                                )
                                                            WHEN item_after_name -> 'itemInfo' -> 'data' -> 'value' ->> 'dispVal' = '使用しない'
                                                                THEN jsonb_set(
                                                                    item_after_name,
                                                                    '{itemInfo,data,value,dispVal}',
                                                                    '"手動"'::jsonb,
                                                                    false
                                                                )
                                                            ELSE item_after_name
                                                        END
                                                    FROM
                                                        (
                                                            SELECT
                                                                CASE
                                                                    WHEN item.elem -> 'itemInfo' ->> 'itemName' = '自動ワンショット'
                                                                        THEN jsonb_set(
                                                                            item.elem,
                                                                            '{itemInfo,itemName}',
                                                                            '"IPワンショットスタート"'::jsonb,
                                                                            false
                                                                        )
                                                                    ELSE item.elem
                                                                END AS item_after_name
                                                        ) AS tmp
                                                )
                                            ELSE item.elem
                                        END
                                        ORDER BY item.ord
                                    )
                                FROM
                                    jsonb_array_elements(cat.elem -> 'subCategoryItem')
                                        WITH ORDINALITY AS item(elem, ord)
                            ),
                            false
                        )
                    ELSE cat.elem
                END
                ORDER BY cat.ord
            )
        FROM
            jsonb_array_elements(approve_content)
                WITH ORDINALITY AS cat(elem, ord)
    )
WHERE
    approve_content IS NOT NULL
    AND jsonb_typeof(approve_content) = 'array'
    AND EXISTS (
        SELECT
            1
        FROM
            jsonb_array_elements(approve_content) AS cat(elem),
            jsonb_array_elements(
                CASE
                    WHEN jsonb_typeof(cat.elem -> 'subCategoryItem') = 'array'
                        THEN cat.elem -> 'subCategoryItem'
                    ELSE '[]'::jsonb
                END
            ) AS item(elem)
        WHERE
            cat.elem ->> 'subCategoryNo' = '4'
            AND item.elem -> 'itemInfo' ->> 'itemNo' = '34'
            AND (
                item.elem -> 'itemInfo' ->> 'itemName' = '自動ワンショット'
                OR item.elem -> 'itemInfo' -> 'data' -> 'value' ->> 'dispVal'
                    IN ('使用する', '使用しない')
            )
    );


-- 治療状況マップ確認時指示内容(content_for_map)
UPDATE ntss.pat_ind_approve
SET
    content_for_map = (
        SELECT
            jsonb_agg(
                CASE
                    WHEN cat.elem ->> 'subCategoryNo' = '4'
                     AND jsonb_typeof(cat.elem -> 'subCategoryItem') = 'array'
                        THEN jsonb_set(
                            cat.elem,
                            '{subCategoryItem}',
                            (
                                SELECT
                                    jsonb_agg(
                                        CASE
                                            WHEN item.elem -> 'itemInfo' ->> 'itemNo' = '34'
                                                THEN (
                                                    SELECT
                                                        CASE
                                                            WHEN item_after_name -> 'itemInfo' -> 'data' -> 'value' ->> 'dispVal' = '使用する'
                                                                THEN jsonb_set(
                                                                    item_after_name,
                                                                    '{itemInfo,data,value,dispVal}',
                                                                    '"自動"'::jsonb,
                                                                    false
                                                                )
                                                            WHEN item_after_name -> 'itemInfo' -> 'data' -> 'value' ->> 'dispVal' = '使用しない'
                                                                THEN jsonb_set(
                                                                    item_after_name,
                                                                    '{itemInfo,data,value,dispVal}',
                                                                    '"手動"'::jsonb,
                                                                    false
                                                                )
                                                            ELSE item_after_name
                                                        END
                                                    FROM
                                                        (
                                                            SELECT
                                                                CASE
                                                                    WHEN item.elem -> 'itemInfo' ->> 'itemName' = '自動ワンショット'
                                                                        THEN jsonb_set(
                                                                            item.elem,
                                                                            '{itemInfo,itemName}',
                                                                            '"IPワンショットスタート"'::jsonb,
                                                                            false
                                                                        )
                                                                    ELSE item.elem
                                                                END AS item_after_name
                                                        ) AS tmp
                                                )
                                            ELSE item.elem
                                        END
                                        ORDER BY item.ord
                                    )
                                FROM
                                    jsonb_array_elements(cat.elem -> 'subCategoryItem')
                                        WITH ORDINALITY AS item(elem, ord)
                            ),
                            false
                        )
                    ELSE cat.elem
                END
                ORDER BY cat.ord
            )
        FROM
            jsonb_array_elements(content_for_map)
                WITH ORDINALITY AS cat(elem, ord)
    )
WHERE
    content_for_map IS NOT NULL
    AND jsonb_typeof(content_for_map) = 'array'
    AND EXISTS (
        SELECT
            1
        FROM
            jsonb_array_elements(content_for_map) AS cat(elem),
            jsonb_array_elements(
                CASE
                    WHEN jsonb_typeof(cat.elem -> 'subCategoryItem') = 'array'
                        THEN cat.elem -> 'subCategoryItem'
                    ELSE '[]'::jsonb
                END
            ) AS item(elem)
        WHERE
            cat.elem ->> 'subCategoryNo' = '4'
            AND item.elem -> 'itemInfo' ->> 'itemNo' = '34'
            AND (
                item.elem -> 'itemInfo' ->> 'itemName' = '自動ワンショット'
                OR item.elem -> 'itemInfo' -> 'data' -> 'value' ->> 'dispVal'
                    IN ('使用する', '使用しない')
            )
    );
