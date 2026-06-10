
ALTER TABLE "ntss"."mst_report" 
  ADD COLUMN "up_user" varchar(16);

COMMENT ON COLUMN "ntss"."mst_report"."up_user" IS '更新者';


