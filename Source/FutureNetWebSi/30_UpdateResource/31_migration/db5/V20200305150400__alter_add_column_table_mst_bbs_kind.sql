ALTER TABLE mst_bbs_kind
RENAME fixed_phrase TO default_contents;
ALTER TABLE mst_bbs_kind
ADD COLUMN default_title character varying;

COMMENT ON COLUMN "mst_bbs_kind"."default_contents" IS E'デフォルト内容';
COMMENT ON COLUMN "mst_bbs_kind"."default_title" IS E'デフォルトタイトル';
