-- 医療材料セットマスタ.セット情報 デフォルト値 設定
UPDATE mst_equipment_set
SET
    set_info = '[]'
WHERE
    set_info IS NULL
;
