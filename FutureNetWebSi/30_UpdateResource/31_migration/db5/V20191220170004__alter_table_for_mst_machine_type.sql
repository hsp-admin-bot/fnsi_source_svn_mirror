-- 項目追加
ALTER TABLE mst_machine_type
 ADD COLUMN com_type jsonb,
 ADD COLUMN treat_mode character varying(10);
-- コメント追加
COMMENT ON COLUMN "mst_machine_type"."com_type" IS E'通信種別';
COMMENT ON COLUMN "mst_machine_type"."treat_mode" IS E'装置モード';