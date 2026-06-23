-- 項目「更新者」削除
ALTER TABLE "ntss"."mst_report" DROP COLUMN "up_user";

-- 項目「帳票更新履歴」追加
ALTER TABLE "ntss"."mst_report" ADD "report_hst_info" jsonb NULL;
COMMENT ON COLUMN "ntss"."mst_report"."report_hst_info" IS '帳票更新履歴';

