ALTER TABLE "ntss"."mnt_weight_state" 
  ADD COLUMN "scale_value_list" varchar;

COMMENT ON COLUMN "ntss"."mnt_weight_state"."scale_value_list" IS '体重値候補リスト';