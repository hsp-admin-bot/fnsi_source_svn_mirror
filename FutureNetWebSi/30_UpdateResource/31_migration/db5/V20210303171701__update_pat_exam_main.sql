ALTER TABLE "ntss"."pat_exam_main"
  ADD COLUMN "exam_week" int2,
  ADD COLUMN "exam_from" timestamp(0),
  ADD COLUMN "exam_to" timestamp(0),
  ADD COLUMN "exam_pattern" int2;

COMMENT ON COLUMN "ntss"."pat_exam_main"."exam_week" IS '指定曜日';

COMMENT ON COLUMN "ntss"."pat_exam_main"."exam_from" IS '指定期間開始日';

COMMENT ON COLUMN "ntss"."pat_exam_main"."exam_to" IS '指定期間終了日';

COMMENT ON COLUMN "ntss"."pat_exam_main"."exam_pattern" IS '検査依頼パターン';
