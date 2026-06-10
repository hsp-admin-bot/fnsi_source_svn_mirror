-- インデックスの削除(体重計測定記録)
DROP INDEX IF EXISTS "ntss"."idx_ord_weight_scale_01";
-- インデックスの追加(体重計測定記録)
CREATE INDEX "idx_ord_weight_scale_01" ON "ntss"."ord_weight_scale" USING btree (
  "ord_no" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "pat_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "measure_date" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
