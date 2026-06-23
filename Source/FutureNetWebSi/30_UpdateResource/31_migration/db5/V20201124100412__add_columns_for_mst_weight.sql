-- mst_weightに列を追加
ALTER TABLE
  mst_weight
ADD COLUMN data_send_interval smallint,
ADD COLUMN data_select_type character varying(1);

-- コメント追加
COMMENT ON COLUMN "mst_weight"."data_send_interval" IS '測定値送信間隔';
COMMENT ON COLUMN "mst_weight"."data_select_type" IS '初期データ表示種別';