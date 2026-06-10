-- テーブルユーザーの新しい列を追加
ALTER TABLE mst_user ADD COLUMN card_idm character varying;
-- コメント追加（利用者マスタ）
COMMENT ON COLUMN "mst_user"."card_idm" IS E'アクセスカード番号';
