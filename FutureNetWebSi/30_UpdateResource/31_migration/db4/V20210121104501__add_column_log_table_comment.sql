ALTER TABLE log_table_comment ADD COLUMN pk_flg numeric;
COMMENT ON COLUMN "log_table_comment"."pk_flg" IS E'PKフラグ';

ALTER TABLE log_table_comment ADD COLUMN delete_flg numeric DEFAULT null;
COMMENT ON COLUMN "log_table_comment"."delete_flg" IS E'削除フラグ';