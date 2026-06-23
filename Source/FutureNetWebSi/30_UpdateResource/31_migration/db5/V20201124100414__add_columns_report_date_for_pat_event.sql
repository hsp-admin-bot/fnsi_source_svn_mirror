ALTER TABLE "ntss"."pat_event" 
  ADD COLUMN "report_date" varchar(10);

COMMENT ON COLUMN "ntss"."pat_event"."report_date" IS '転入転出日付';