ALTER TABLE "ntss"."mst_machine" 
  ADD COLUMN "blood_purify_type" character varying DEFAULT '5',
  ADD COLUMN "is_blood_purify_use" character varying DEFAULT '1';

COMMENT ON COLUMN "ntss"."mst_machine"."is_blood_purify_use" IS '特殊浄化通信アプリ使用選択';
COMMENT ON COLUMN "ntss"."mst_machine"."blood_purify_type" IS '特殊浄化装置種別';
