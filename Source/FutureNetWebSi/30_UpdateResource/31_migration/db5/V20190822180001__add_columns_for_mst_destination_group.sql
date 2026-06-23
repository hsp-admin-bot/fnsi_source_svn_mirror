-- 送信先グループマスタにメーカー通知フラグを追加
ALTER TABLE
  mst_destination_group
ADD COLUMN is_notice character varying(1) DEFAULT '0';  --メーカー通知フラグ
COMMENT ON COLUMN "mst_destination_group"."is_notice" IS E'メーカー通知フラグ';
