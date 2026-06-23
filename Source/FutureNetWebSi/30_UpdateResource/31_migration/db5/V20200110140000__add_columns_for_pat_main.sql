ALTER TABLE pat_main
ADD COLUMN sch_ext_end_date character varying(8),
ADD COLUMN sch_ext_status character varying(1) DEFAULT '0';

COMMENT ON COLUMN "pat_main"."sch_ext_end_date" IS E'スケジュール延長最終日';
COMMENT ON COLUMN "pat_main"."sch_ext_status" IS E'スケジュール延長処理ステータス';