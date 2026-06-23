-- 薬剤セットマスタ.セット情報 デフォルト値 設定
UPDATE mst_medicine_set
SET
    set_info = '[]'
WHERE
    set_info IS NULL
;
