-- ord_coop_noに列を追加
ALTER TABLE
  ord_coop_no
ADD COLUMN status character varying(1) DEFAULT '0';

-- コメント追加
COMMENT ON COLUMN "ord_coop_no"."status" IS 'ステータス 0：未処理、1：処理済';