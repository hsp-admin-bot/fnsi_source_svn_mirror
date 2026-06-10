--ord_material_saveにインデックスを追加(データ基準番号)
CREATE INDEX "ord_material_save_supplies_base_no" ON "ntss"."ord_material_save" USING btree (
  "supplies_base_no" "pg_catalog"."int8_ops" ASC NULLS LAST
);
