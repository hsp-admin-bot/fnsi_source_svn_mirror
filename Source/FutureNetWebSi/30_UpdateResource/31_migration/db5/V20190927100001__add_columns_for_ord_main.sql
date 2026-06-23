--ord_mainにカラムを追加
alter table ord_main add treat_type numeric(1,0);
COMMENT ON COLUMN "ord_main"."treat_type" IS E'治療種別';
