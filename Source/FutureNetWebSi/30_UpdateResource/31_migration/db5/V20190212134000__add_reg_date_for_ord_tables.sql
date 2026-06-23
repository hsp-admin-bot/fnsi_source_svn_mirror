ALTER TABLE
  ord_main
ADD COLUMN
  reg_date timestamp(3)
;
COMMENT ON COLUMN "ord_main"."reg_date" IS E'登録日時';

ALTER TABLE
  ord_schedule
ADD COLUMN
  reg_date timestamp(3)
;
COMMENT ON COLUMN "ord_schedule"."reg_date" IS E'登録日時';
