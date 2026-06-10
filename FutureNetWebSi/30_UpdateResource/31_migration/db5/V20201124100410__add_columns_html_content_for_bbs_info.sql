ALTER TABLE "ntss"."bbs_info" 
  ADD COLUMN "html_content" varchar;

COMMENT ON COLUMN "ntss"."bbs_info"."html_content" IS '様式付きの内容';

update "ntss"."bbs_info" set html_content = content;
