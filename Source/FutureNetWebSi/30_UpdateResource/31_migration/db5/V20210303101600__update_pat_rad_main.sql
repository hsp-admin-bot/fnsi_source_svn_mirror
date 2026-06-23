ALTER TABLE "ntss"."pat_rad_main" 
  ADD COLUMN "rad_week" int2,
  ADD COLUMN "rad_pattern" int2,
  ADD COLUMN "rad_from" timestamp(3),
  ADD COLUMN "rad_to" timestamp(3);

COMMENT ON COLUMN "ntss"."pat_rad_main"."rad_week" IS '指定曜日';

COMMENT ON COLUMN "ntss"."pat_rad_main"."rad_pattern" IS '放射線検査依頼パターン';

COMMENT ON COLUMN "ntss"."pat_rad_main"."rad_from" IS '指定期間開始日';

COMMENT ON COLUMN "ntss"."pat_rad_main"."rad_to" IS '指定期間終了日';