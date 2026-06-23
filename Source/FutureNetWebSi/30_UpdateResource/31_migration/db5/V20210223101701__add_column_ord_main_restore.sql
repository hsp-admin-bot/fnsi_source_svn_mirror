ALTER TABLE ord_main_restore ADD COLUMN up_ind_user_id bigint;
COMMENT ON COLUMN "ord_main_restore"."up_ind_user_id" IS E'最終更新指示者ID';

ALTER TABLE ord_main_restore ADD COLUMN up_user_id bigint;
COMMENT ON COLUMN "ord_main_restore"."up_user_id" IS E'最終更新者ID';
