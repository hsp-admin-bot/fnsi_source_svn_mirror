DROP INDEX IF EXISTS "ntss"."pat_insurance_pat_id_is_disp_is_del_idx";

CREATE INDEX "pat_insurance_pat_id_is_disp_is_del_idx" ON "ntss"."pat_insurance" USING btree (
    "pat_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);

DROP INDEX IF EXISTS idx_pat_personal_main_01;

CREATE INDEX idx_pat_personal_main_01 ON pat_personal_main USING btree ("is_del" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST);