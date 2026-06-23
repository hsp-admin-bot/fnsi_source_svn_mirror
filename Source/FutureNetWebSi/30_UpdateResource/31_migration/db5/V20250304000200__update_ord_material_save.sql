DO $$
BEGIN
    -- フィールドがテーブルに存在するかどうかを判断する
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'ord_material_save'
          AND column_name = 'receipt_unit'
    ) THEN
        -- フィールドが存在しない場合はフィールドを追加
        ALTER TABLE ntss.ord_material_save ADD receipt_unit varchar NULL;
COMMENT ON COLUMN ntss.ord_material_save.receipt_unit IS 'レセ単位';

    END IF;
END $$;
