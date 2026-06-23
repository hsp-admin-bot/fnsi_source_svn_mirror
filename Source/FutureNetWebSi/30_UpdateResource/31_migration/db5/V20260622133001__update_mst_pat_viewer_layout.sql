-- #12726：不正文言修正
-- 以下文言修正に伴い、患者経過総合ビューアレイアウトマスタ(mst_pat_viewer_layout)テーブル．表示項目(disp_item_info)カラムのデータ修正を行う。
-- 修正内容：
--    Qb・Qdプログラム→QB・QDプログラム ※完全一致 かつ 大文字小文字区別
--    I-HDF→I-HDF設定 ※完全一致 かつ 大文字小文字区別
-- 修正対象：
--    QB・QDプログラム："categoryNo"が1 かつ "subCategoryNo"が13 かつ "itemNo"が1
--    I-HDF設定       ："categoryNo"が1 かつ "subCategoryNo"が14 かつ "itemNo"が1
-- update時考慮内容：
--    ・json構造と配列順序の維持
--    ・存在しないキーを追加しない
--    ・空配列をnullで更新しない

-- 「Qb・Qdプログラム」を「QB・QDプログラム」へ文言修正
UPDATE ntss.mst_pat_viewer_layout
SET
    disp_item_info = (
        SELECT
            COALESCE(
                jsonb_agg(
                    CASE
                        WHEN category.elem ->> 'categoryNo' = '1'
                         AND jsonb_typeof(category.elem -> 'categoryItem') = 'array'
                            THEN jsonb_set(
                                category.elem,
                                '{categoryItem}',
                                (
                                    SELECT
                                        COALESCE(
                                            jsonb_agg(
                                                CASE
                                                    WHEN sub_category.elem ->> 'subCategoryNo' = '13'
                                                        THEN
                                                            CASE
                                                                WHEN jsonb_typeof(sub_category_after_name.elem -> 'subCategoryItem') = 'array'
                                                                    THEN jsonb_set(
                                                                        sub_category_after_name.elem,
                                                                        '{subCategoryItem}',
                                                                        (
                                                                            SELECT
                                                                                COALESCE(
                                                                                    jsonb_agg(
                                                                                        CASE
                                                                                            WHEN item.elem ->> 'itemNo' = '1'
                                                                                             AND item.elem ->> 'itemName' = 'Qb・Qdプログラム'
                                                                                                THEN jsonb_set(
                                                                                                    item.elem,
                                                                                                    '{itemName}',
                                                                                                    '"QB・QDプログラム"'::jsonb,
                                                                                                    false
                                                                                                )
                                                                                            ELSE item.elem
                                                                                        END
                                                                                        ORDER BY item.ord
                                                                                    ),
                                                                                    sub_category_after_name.elem -> 'subCategoryItem'
                                                                                )
                                                                            FROM
                                                                                jsonb_array_elements(sub_category_after_name.elem -> 'subCategoryItem')
                                                                                    WITH ORDINALITY AS item(elem, ord)
                                                                        ),
                                                                        false
                                                                    )
                                                                ELSE sub_category_after_name.elem
                                                            END
                                                    ELSE sub_category.elem
                                                END
                                                ORDER BY sub_category.ord
                                            ),
                                            category.elem -> 'categoryItem'
                                        )
                                    FROM
                                        jsonb_array_elements(category.elem -> 'categoryItem')
                                            WITH ORDINALITY AS sub_category(elem, ord)
                                        CROSS JOIN LATERAL (
                                            SELECT
                                                CASE
                                                    WHEN sub_category.elem ->> 'subCategoryName' = 'Qb・Qdプログラム'
                                                        THEN jsonb_set(
                                                            sub_category.elem,
                                                            '{subCategoryName}',
                                                            '"QB・QDプログラム"'::jsonb,
                                                            false
                                                        )
                                                    ELSE sub_category.elem
                                                END AS elem
                                        ) AS sub_category_after_name
                                ),
                                false
                            )
                        ELSE category.elem
                    END
                    ORDER BY category.ord
                ),
                disp_item_info
            )
        FROM
            jsonb_array_elements(disp_item_info)
                WITH ORDINALITY AS category(elem, ord)
    )
WHERE
    jsonb_typeof(disp_item_info) = 'array'
    AND EXISTS (
        SELECT
            1
        FROM
            jsonb_array_elements(disp_item_info) AS category(elem)
            CROSS JOIN LATERAL jsonb_array_elements(
                CASE
                    WHEN jsonb_typeof(category.elem -> 'categoryItem') = 'array'
                        THEN category.elem -> 'categoryItem'
                    ELSE '[]'::jsonb
                END
            ) AS sub_category(elem)
            LEFT JOIN LATERAL jsonb_array_elements(
                CASE
                    WHEN jsonb_typeof(sub_category.elem -> 'subCategoryItem') = 'array'
                        THEN sub_category.elem -> 'subCategoryItem'
                    ELSE '[]'::jsonb
                END
            ) AS item(elem) ON true
        WHERE
            category.elem ->> 'categoryNo' = '1'
            AND sub_category.elem ->> 'subCategoryNo' = '13'
            AND (
                sub_category.elem ->> 'subCategoryName' = 'Qb・Qdプログラム'
                OR (
                    item.elem ->> 'itemNo' = '1'
                    AND item.elem ->> 'itemName' = 'Qb・Qdプログラム'
                )
            )
    );


-- 「I-HDF」を「I-HDF設定」へ文言修正
UPDATE ntss.mst_pat_viewer_layout
SET
    disp_item_info = (
        SELECT
            COALESCE(
                jsonb_agg(
                    CASE
                        WHEN category.elem ->> 'categoryNo' = '1'
                         AND jsonb_typeof(category.elem -> 'categoryItem') = 'array'
                            THEN jsonb_set(
                                category.elem,
                                '{categoryItem}',
                                (
                                    SELECT
                                        COALESCE(
                                            jsonb_agg(
                                                CASE
                                                    WHEN sub_category.elem ->> 'subCategoryNo' = '14'
                                                        THEN
                                                            CASE
                                                                WHEN jsonb_typeof(sub_category_after_name.elem -> 'subCategoryItem') = 'array'
                                                                    THEN jsonb_set(
                                                                        sub_category_after_name.elem,
                                                                        '{subCategoryItem}',
                                                                        (
                                                                            SELECT
                                                                                COALESCE(
                                                                                    jsonb_agg(
                                                                                        CASE
                                                                                            WHEN item.elem ->> 'itemNo' = '1'
                                                                                             AND item.elem ->> 'itemName' = 'I-HDF'
                                                                                                THEN jsonb_set(
                                                                                                    item.elem,
                                                                                                    '{itemName}',
                                                                                                    '"I-HDF設定"'::jsonb,
                                                                                                    false
                                                                                                )
                                                                                            ELSE item.elem
                                                                                        END
                                                                                        ORDER BY item.ord
                                                                                    ),
                                                                                    sub_category_after_name.elem -> 'subCategoryItem'
                                                                                )
                                                                            FROM
                                                                                jsonb_array_elements(sub_category_after_name.elem -> 'subCategoryItem')
                                                                                    WITH ORDINALITY AS item(elem, ord)
                                                                        ),
                                                                        false
                                                                    )
                                                                ELSE sub_category_after_name.elem
                                                            END
                                                    ELSE sub_category.elem
                                                END
                                                ORDER BY sub_category.ord
                                            ),
                                            category.elem -> 'categoryItem'
                                        )
                                    FROM
                                        jsonb_array_elements(category.elem -> 'categoryItem')
                                            WITH ORDINALITY AS sub_category(elem, ord)
                                        CROSS JOIN LATERAL (
                                            SELECT
                                                CASE
                                                    WHEN sub_category.elem ->> 'subCategoryName' = 'I-HDF'
                                                        THEN jsonb_set(
                                                            sub_category.elem,
                                                            '{subCategoryName}',
                                                            '"I-HDF設定"'::jsonb,
                                                            false
                                                        )
                                                    ELSE sub_category.elem
                                                END AS elem
                                        ) AS sub_category_after_name
                                ),
                                false
                            )
                        ELSE category.elem
                    END
                    ORDER BY category.ord
                ),
                disp_item_info
            )
        FROM
            jsonb_array_elements(disp_item_info)
                WITH ORDINALITY AS category(elem, ord)
    )
WHERE
    jsonb_typeof(disp_item_info) = 'array'
    AND EXISTS (
        SELECT
            1
        FROM
            jsonb_array_elements(disp_item_info) AS category(elem)
            CROSS JOIN LATERAL jsonb_array_elements(
                CASE
                    WHEN jsonb_typeof(category.elem -> 'categoryItem') = 'array'
                        THEN category.elem -> 'categoryItem'
                    ELSE '[]'::jsonb
                END
            ) AS sub_category(elem)
            LEFT JOIN LATERAL jsonb_array_elements(
                CASE
                    WHEN jsonb_typeof(sub_category.elem -> 'subCategoryItem') = 'array'
                        THEN sub_category.elem -> 'subCategoryItem'
                    ELSE '[]'::jsonb
                END
            ) AS item(elem) ON true
        WHERE
            category.elem ->> 'categoryNo' = '1'
            AND sub_category.elem ->> 'subCategoryNo' = '14'
            AND (
                sub_category.elem ->> 'subCategoryName' = 'I-HDF'
                OR (
                    item.elem ->> 'itemNo' = '1'
                    AND item.elem ->> 'itemName' = 'I-HDF'
                )
            )
    );
