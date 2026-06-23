DROP INDEX IF EXISTS unq_mnt_mainte_main_02;
DROP INDEX IF EXISTS idx_mnt_mainte_main_01;
CREATE INDEX "idx_mnt_mainte_main_01" ON "ntss"."mnt_mainte_main" USING btree (
  "machine_no" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "mainte_layout_cd" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "mainte_date" "pg_catalog"."timestamp_ops" ASC NULLS LAST,
  "mainte_layout_group_cd" "pg_catalog"."int8_ops" ASC NULLS LAST
) WHERE is_del::text = '0'::text;