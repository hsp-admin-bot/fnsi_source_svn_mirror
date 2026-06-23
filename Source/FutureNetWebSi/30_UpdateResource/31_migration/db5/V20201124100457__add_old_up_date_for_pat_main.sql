ALTER TABLE
  pat_main
ADD COLUMN
  old_up_date timestamp(3)
;
COMMENT ON COLUMN "pat_main"."old_up_date" IS '旧更新日時';
