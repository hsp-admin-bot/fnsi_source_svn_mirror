-- #12478 自動ワンショット(使用する/使用しない)→IPワンショットスタート(自動/手動)修正
-- 以下文言修正に伴い、患者経過総合ビューアレイアウトマスタ(mst_pat_viewer_layout)テーブル．表示項目(disp_item_info)カラムのデータ修正を行う。
-- 修正内容：自動ワンショット→IPワンショットスタート
-- 修正対象："categoryNo"が1 かつ "subCategoryNo"が4 かつ "itemNo"が34

-- 「自動ワンショット」を「IPワンショットスタート」へ文言修正
UPDATE ntss.mst_pat_viewer_layout
SET
    disp_item_info = (
        SELECT
            jsonb_agg(
                CASE
                    WHEN category.elem ->> 'categoryNo' = '1'
                     AND jsonb_typeof(category.elem -> 'categoryItem') = 'array'
                        THEN jsonb_set(
                            category.elem,
                            '{categoryItem}',
                            (
                                SELECT
                                    jsonb_agg(
                                        CASE
                                            WHEN sub_category.elem ->> 'subCategoryNo' = '4'
                                             AND jsonb_typeof(sub_category.elem -> 'subCategoryItem') = 'array'
                                                THEN jsonb_set(
                                                    sub_category.elem,
                                                    '{subCategoryItem}',
                                                    (
                                                        SELECT
                                                            jsonb_agg(
                                                                CASE
                                                                    WHEN item.elem ->> 'itemNo' = '34'
                                                                     AND item.elem ->> 'itemName' = '自動ワンショット'
                                                                        THEN jsonb_set(
                                                                            item.elem,
                                                                            '{itemName}',
                                                                            '"IPワンショットスタート"'::jsonb,
                                                                            false
                                                                        )
                                                                    ELSE item.elem
                                                                END
                                                                ORDER BY item.ord
                                                            )
                                                        FROM
                                                            jsonb_array_elements(sub_category.elem -> 'subCategoryItem')
                                                                WITH ORDINALITY AS item(elem, ord)
                                                    ),
                                                    false
                                                )
                                            ELSE sub_category.elem
                                        END
                                        ORDER BY sub_category.ord
                                    )
                                FROM
                                    jsonb_array_elements(category.elem -> 'categoryItem')
                                        WITH ORDINALITY AS sub_category(elem, ord)
                            ),
                            false
                        )
                    ELSE category.elem
                END
                ORDER BY category.ord
            )
        FROM
            jsonb_array_elements(disp_item_info)
                WITH ORDINALITY AS category(elem, ord)
    )
WHERE
    disp_item_info IS NOT NULL
    AND jsonb_typeof(disp_item_info) = 'array'
    AND EXISTS (
        SELECT
            1
        FROM
            jsonb_array_elements(disp_item_info) AS category(elem),
            jsonb_array_elements(
                CASE
                    WHEN jsonb_typeof(category.elem -> 'categoryItem') = 'array'
                        THEN category.elem -> 'categoryItem'
                    ELSE '[]'::jsonb
                END
            ) AS sub_category(elem),
            jsonb_array_elements(
                CASE
                    WHEN jsonb_typeof(sub_category.elem -> 'subCategoryItem') = 'array'
                        THEN sub_category.elem -> 'subCategoryItem'
                    ELSE '[]'::jsonb
                END
            ) AS item(elem)
        WHERE
            category.elem ->> 'categoryNo' = '1'
            AND sub_category.elem ->> 'subCategoryNo' = '4'
            AND item.elem ->> 'itemNo' = '34'
            AND item.elem ->> 'itemName' = '自動ワンショット'
    );
