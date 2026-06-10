DO $$
BEGIN
    -- フィールドがテーブルに存在するかどうかを判断する
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'ord_material_save'
          AND column_name = 'effect_flg'
    ) THEN
        -- フィールドが存在しない場合はフィールドを追加
        ALTER TABLE ntss.ord_material_save ADD effect_flg varchar NULL;
COMMENT ON COLUMN ntss.ord_material_save.effect_flg IS '投与済みフラグ：１済み、0未投与';

    END IF;
END $$;
