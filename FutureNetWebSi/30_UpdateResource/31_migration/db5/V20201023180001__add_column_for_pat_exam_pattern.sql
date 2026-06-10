--pat_exam_patternに列を追加する
ALTER TABLE
  pat_exam_pattern
ADD COLUMN IF NOT EXISTS ind_user_id bigint --指示者
;

COMMENT ON COLUMN "pat_exam_pattern"."ind_user_id" IS E'指示者';

