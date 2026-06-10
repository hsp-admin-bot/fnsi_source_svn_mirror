-- テーブル作成
ALTER TABLE mst_addition 
 ALTER COLUMN addition_short_name  type character varying(20),
 ALTER COLUMN addition_limit  type integer;

 --コメント追加
 COMMENT ON COLUMN "mst_addition"."addition_limit_type" IS E'算定回数上限型式';
