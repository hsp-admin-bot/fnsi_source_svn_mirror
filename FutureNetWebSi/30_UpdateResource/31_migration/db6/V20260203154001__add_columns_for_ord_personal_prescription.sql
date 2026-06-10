-- #11063 処方情報 カラム追加
ALTER TABLE ord_personal_prescription ADD COLUMN is_refill character varying(1) not null DEFAULT '0';
ALTER TABLE ord_personal_prescription ADD COLUMN refill_num integer;

COMMENT ON COLUMN "ord_personal_prescription"."is_refill" IS E'リフィル可';
COMMENT ON COLUMN "ord_personal_prescription"."refill_num" IS E'リフィル回数';
