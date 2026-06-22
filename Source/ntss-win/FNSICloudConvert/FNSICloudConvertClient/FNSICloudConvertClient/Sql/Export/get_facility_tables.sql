-- 施設コードに紐づくテーブル一覧を取得する
-- パラメーター:
--   :facilityCd  施設コード (例: 'F001')
SELECT
    table_name
FROM
    information_schema.tables
WHERE
    table_schema = 'public'
    AND table_type = 'BASE TABLE'
ORDER BY
    table_name
