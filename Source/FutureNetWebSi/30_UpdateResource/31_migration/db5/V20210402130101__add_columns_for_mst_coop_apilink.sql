--mst_coop_apilinkに列を追加

ALTER TABLE "mst_coop_apilink" ADD COLUMN "api_type" character varying(1); --API種別
ALTER TABLE "mst_coop_apilink" ADD COLUMN "sql_setting" jsonb; --sql設定

COMMENT ON COLUMN "mst_coop_apilink"."api_type" IS E'API種別';
COMMENT ON COLUMN "mst_coop_apilink"."sql_setting" IS E'sql設定';
