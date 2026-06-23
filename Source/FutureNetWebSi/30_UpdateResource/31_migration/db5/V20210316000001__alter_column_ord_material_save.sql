ALTER TABLE ord_material_save
    ALTER COLUMN supplies_base_no SET data TYPE bigint USING supplies_base_no::bigint;
