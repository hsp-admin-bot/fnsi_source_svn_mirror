-- 患者番号（連携用）追加
ALTER TABLE
  ord_coop_no
ADD COLUMN hosp_pat_id character varying(12);

COMMENT ON COLUMN "ord_coop_no"."hosp_pat_id" IS E'患者番号（連携用）';
