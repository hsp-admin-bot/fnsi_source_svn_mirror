--mst_treatmentに列を追加
ALTER TABLE "ntss"."mst_treatment" ADD COLUMN "report_id_act" int4;
COMMENT ON COLUMN "ntss"."mst_treatment"."report_id_act" IS '治療経過表ID（実績確定）';