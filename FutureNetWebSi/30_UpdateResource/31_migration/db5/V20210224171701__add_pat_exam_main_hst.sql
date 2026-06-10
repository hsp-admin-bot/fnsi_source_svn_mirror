CREATE SEQUENCE exam_main_hst_cd_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "pat_exam_main_hst"
  DROP CONSTRAINT "pat_exam_main_hst_pkey",
  ADD COLUMN "exam_main_hst_cd" int8 NOT NULL default nextval('exam_main_hst_cd_seq'),
  ADD CONSTRAINT "pat_exam_main_hst_pkey" PRIMARY KEY ("exam_main_hst_cd");

COMMENT ON COLUMN "pat_exam_main_hst"."exam_main_hst_cd" IS '患者検査結果記録コード';
