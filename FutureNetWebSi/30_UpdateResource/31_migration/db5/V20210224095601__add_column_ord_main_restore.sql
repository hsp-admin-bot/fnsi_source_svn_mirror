ALTER TABLE ord_main_restore ADD COLUMN reg_date timestamp(3);
COMMENT ON COLUMN "ord_main_restore"."reg_date" IS E'登録日時';

ALTER TABLE ord_main_restore ADD COLUMN treat_type numeric(1,0);
COMMENT ON COLUMN "ord_main_restore"."treat_type" IS E'治療種別';

ALTER TABLE ord_main_restore ADD COLUMN rst_purification_cnt integer;
COMMENT ON COLUMN "ord_main_restore"."rst_purification_cnt" IS E'実績：特殊浄化回数';

ALTER TABLE ord_main_restore ADD COLUMN rst_dw numeric(5,2);
COMMENT ON COLUMN "ord_main_restore"."rst_dw" IS E'実績：DW';

ALTER TABLE ord_main_restore ADD COLUMN weight_scale_no bigint;
COMMENT ON COLUMN "ord_main_restore"."weight_scale_no" IS E'実績：体重測定記録番号';

ALTER TABLE ord_main_restore ADD COLUMN fn_plural numeric(1,0);
COMMENT ON COLUMN "ord_main_restore"."fn_plural" IS E'指示：FNW+同日複数回';

ALTER TABLE ord_main_restore ADD COLUMN is_confirm character varying(1);
COMMENT ON COLUMN "ord_main_restore"."is_confirm" IS E'実績：確定フラグ';

ALTER TABLE ord_main_restore ADD COLUMN ind_dw numeric(5,2);
COMMENT ON COLUMN "ord_main_restore"."ind_dw" IS E'指示：DW';

ALTER TABLE ord_main_restore ADD COLUMN addition_info jsonb;
COMMENT ON COLUMN "ord_main_restore"."addition_info" IS E'加算情報';