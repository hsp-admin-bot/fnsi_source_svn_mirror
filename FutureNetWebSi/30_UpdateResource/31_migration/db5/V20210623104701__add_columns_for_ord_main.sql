ALTER TABLE ord_main ADD COLUMN rst_edition_date timestamp(3);
COMMENT ON COLUMN "ord_main"."rst_edition_date" IS E'初版確定日時';

ALTER TABLE ord_main ADD COLUMN cur_edition_date timestamp(3);
COMMENT ON COLUMN "ord_main"."cur_edition_date" IS E'最新版確定日時';