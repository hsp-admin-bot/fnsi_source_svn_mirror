
ALTER TABLE "ntss"."pat_event" 
  ADD COLUMN "report_url" varchar(100);

COMMENT ON COLUMN "ntss"."pat_event"."report_url" IS 'テンプレートのアドレス';
